require 'spec_helper'

describe PostsController do
  let(:user){ mock_model(User) }
  
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
      Post.stub(:all).and_return([post])
      get :index
      assigns(:posts).should eq([post])
    end
  end

  describe "GET new" do
    it "has a status of 200" do
      get :new
      response.status.should eq(200)
    end

    it "assigns a blank new post" do
      get :new
      assigns(:post).should be_a Post
      assigns(:post).should be_new_record
    end
  end

  describe "POST create" do
    # Create a real user so that a post can be built for that user
    let(:user){ create(:teacher).user }

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
      let(:make_request){ post :create }

      it "does not create a post" do
        expect{ make_request }.to change{ Post.count }.by(0)
      end
      
      it "renders the new page" do
        make_request
        response.should render_template "new"
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid post"
      end
    end
  end
end