require 'spec_helper'

describe PostsController do
  let(:user){ create(:teacher).user }
  
  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET index" do
    it "redirects to the login path if not logged in" do
      controller.stub(:current_user) 
      get :index
      response.should redirect_to login_path
    end

    it "has a status of 200 if logged in" do
      get :index
      response.status.should eq(200)
    end

    it "finds and assigns all posts" do
      post = mock_model(Post)
      Post.stub(:limit).and_return([post])
      get :index
      assigns(:posts).should eq([post])
    end
  end

  describe "GET show" do
    let(:post){ mock_model(Post) }
    before { Post.stub(:find).and_return(post) }
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the post given by the passed ID" do
      Post.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found post" do
      get :show, id: 5
      assigns(:post).should == post
    end
  end

  describe "GET new" do
    it "has a status of 200" do
      get :new
      response.status.should eq(200)
    end

    it "assigns a new post" do
      get :new
      assigns(:post).should be_a Post
      assigns(:post).should be_new_record
    end

    it "assigns post data from the flash if present" do
      get :new, nil, nil, { post_data: { content: "<p>Preloaded content</p>" } }
      assigns(:post).content.should == "<p>Preloaded content</p>"
    end

    it "initalizes the post tag if flash data is not present" do
      get :new
      assigns(:post).teachers.should == [user.profile]
    end

    it "does not initalize the post tag if flash data is present" do
      get :new, nil, nil, { post_data: { content: "<p>Preloaded content</p>" } }
      assigns(:post).teachers.should be_empty
    end
  end

  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, post: { title: "lorem ipsum" } }

      it "creates a post with the data passed" do
        expect{ make_request }.to change{ Post.count }.by(1)
      end

      it "redirects to the posts page" do
        make_request
        response.should redirect_to posts_path
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, post: { content: "some content" } }

      it "does not create a post" do
        expect{ make_request }.to change{ Post.count }.by(0)
      end
      
      it "redirects to the new page" do
        make_request
        response.should redirect_to new_post_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid post"
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:post_data].should == { "content" => "some content" }
      end
    end
  end
end