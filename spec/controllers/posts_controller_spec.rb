require 'spec_helper'

describe PostsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Post
  end

  describe "GET index" do
    describe "with preset posts" do
      before do
        @student1 = create(:student)
        @student2 = create(:student)
        @student3 = create(:student)
        @group1 = create(:group, students: [@student1, @student2])
        @post1 = create(:post, title: "Post No One", students: [@student1])
        @post2 = create(:post, title: "Post No Two")
        @post3 = create(:post, title: "Post No Three", students: [@student1, @student2])
        @post4 = create(:post, title: "Post Number Four", students: [@student2])
      end

      it "raises an exception if the user cannot read posts" do
        ability.cannot :read, Post
        expect{ get :index, format: :json }.to raise_exception(CanCan::AccessDenied)
      end

      it "has a status of 200 if logged in" do
        get :index, format: :json
        response.status.should eq(200)
      end

      it "sorts posts by the most recent post first" do
        get :index, format: :json
        assigns(:posts).should == [@post4, @post3, @post2, @post1]
      end
    end

    describe "pagination" do
      def create_items(num)
        create_list(:post, num)
      end

      def make_request(page=nil)
        if page
          get :index, page: page, format: :json
        else
          get :index, format: :json
        end
      end

      let(:item_list_name){ :posts }

      it_behaves_like "a paginated page"
    end
  end


  describe "GET show" do
    let(:post){ mock_model(Post) }
    before { Post.stub(:find).and_return(post) }
    let(:make_request) { get :show, id: 5, format: :json }

    it "raises an exception if the user cannot read the post" do
      ability.cannot :read, post
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "finds the post given by the passed ID" do
      Post.should_receive(:find).with("5")
      make_request
    end

    it "assigns the found post" do
      make_request
      assigns(:post).should == post
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, post: { title: "lorem ipsum" }, format: :json }

      it "raises an exception if the user cannot create a post" do
        ability.cannot :create, Post
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a post with the data passed" do
        expect{ make_request }.to change{ Post.count }.by(1)
      end

      it "creates a post with the correct title" do
        make_request
        assigns(:post).title.should == "lorem ipsum"
      end

      it "creates a post with the correct author" do
        make_request
        assigns(:post).author.should == user.profile
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, post: { content: "some content" }, format: :json }

      it "does not create a post" do
        expect{ make_request }.to change{ Post.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "PUT update" do
    let(:post){ create(:post) }

    context "with valid data" do
      let(:make_request){ put :update, id: post.id, post: { title: "lorem ipsum" }, format: :json }

      it "raises an exception if the user cannot update a post" do
        ability.cannot :update, post
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct post" do
        make_request
        assigns(:post).should eq(post)
      end

      it "edits the post title" do
        make_request
        assigns(:post).reload.title.should == "lorem ipsum"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: post.id, post: { title: "", content: "some content" }, format: :json }

      it "does not edit the post" do
        make_request
        post.reload.content.should_not == "some content"
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "DELETE destroy" do
    let(:post){ create(:post) }
    let(:make_request){ delete :destroy, id: post.id, format: :json }

    it "raises an exception if the user cannot destroy a post" do
      ability.cannot :destroy, post
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct post" do
      make_request
      assigns(:post).should eq(post)
    end

    it "destroys the post" do
      make_request
      assigns(:post).should be_destroyed
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end
  end
end