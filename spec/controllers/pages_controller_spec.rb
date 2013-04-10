require 'spec_helper'

describe PagesController do
  let(:user){ mock_model(User) }

  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET home" do
    it "redirects to the login path if not logged in" do
      controller.stub(:current_user)
      get :home
      response.should redirect_to login_path
    end

    it "redirects to the posts page if logged in" do
      get :home, format: :json
      response.should redirect_to posts_path
    end
  end


  describe "GET user" do
    let(:profile){ mock_model(Teacher) }
    before { controller.stub(:current_profile).and_return(profile) }

    it "sets the profile to the current profile" do
      get :user, format: :json
      assigns(:profile).should eq(profile)
    end
  end


  describe "GET people" do
    it "has a status of 200" do
      get :people, format: :json
      response.status.should == 200
    end

    describe "filtering" do
      before do
        @student1 = create(:student, name: "Some Student")
        @student2 = create(:student, name: "Other Student")
        @student3 = create(:student, name: "Archived Student", archived: true)
        @teacher1 = create(:teacher, name: "A Teacher")
        @teacher2 = create(:teacher, name: "Rahul Sekhar")
        @teacher3 = create(:teacher, name: "Archived Teacher", archived: true)
      end

      describe "with no filter parameter" do
        it "assigns any non archived students and teachers alphabetically into a people collection" do
          get :people, format: :json
          assigns(:people).should == [@teacher1, @student2, @teacher2, @student1]
        end

        it "searches if a search parameter is passed" do
          get :people, search: "ther stu", format: :json
          assigns(:people).should == [@student2]
        end
      end

      describe "with an unknown filter parameter" do
        it "assigns any non archived students and teachers alphabetically into a people collection" do
          get :people, filter: "unknown", format: :json
          assigns(:people).should == [@teacher1, @student2, @teacher2, @student1]
        end

        it "searches if a search parameter is passed" do
          get :people, filter: "unknown", search: "ther stu", format: :json
          assigns(:people).should == [@student2]
        end
      end

      describe "archived filter" do
        it "assigns archived students and teachers" do
          get :people, filter: "archived", format: :json
          assigns(:people).should == [@student3, @teacher3]
        end

        it "searches if a search parameter is passed" do
          get :people, filter: "archived", search: "te", format: :json
          assigns(:people).should == [@teacher3]
        end
      end

      describe "students filter" do
        it "assigns current students" do
          get :people, filter: "students", format: :json
          assigns(:people).should == [@student2, @student1]
        end

        it "searches if a search parameter is passed" do
          get :people, filter: "students", search: "some student", format: :json
          assigns(:people).should == [@student1]
        end
      end

      describe "teachers filter" do
        it "assigns current teachers" do
          get :people, filter: "teachers", format: :json
          assigns(:people).should == [@teacher1, @teacher2]
        end

        it "searches if a search parameter is passed" do
          get :people, filter: "teachers", search: "ra", format: :json
          assigns(:people).should == [@teacher2]
        end
      end

      describe "mentees filter" do
        context "when logged in as a student" do
          before{ user.stub(:profile).and_return(create(:student)) }

          it "assigns an empty array to people" do
            get :people, filter: "mentees", format: :json
            assigns(:people).should be_empty
          end
        end

        context "when logged in as a guardian" do
          before{ user.stub(:profile).and_return(create(:guardian)) }

          it "assigns an empty array to people" do
            get :people, filter: "mentees", format: :json
            assigns(:people).should be_empty
          end
        end

        context "when logged in as a teacher" do
          let(:teacher){ create(:teacher) }
          before do
            user.stub(:profile).and_return(teacher)
            teacher.mentees = [@student2, @student3]
          end

          it "assigns the teachers mentees" do
            get :people, filter: "mentees", format: :json
            assigns(:people).should == [@student3, @student2]
          end

          it "searches if a search parameter is passed" do
            get :people, filter: "mentees", search: "arch", format: :json
            assigns(:people).should == [@student3]
          end
        end
      end

      describe "for a non-existing group" do
        it "assigns an empty people array" do
          get :people, filter: "group-67", format: :json
          assigns(:people).should be_empty
        end
      end

      describe "for a group" do
        before do
          @group = Group.create(name: "Group")
          @student4 = create(:student, name: "A Student")
          @group.students = [@student2, @student3, @student4]
        end

        it "assigns the groups current students" do
          get :people, filter: "group-#{@group.id}", format: :json
          assigns(:people).should == [@student4, @student2]
        end

        it "searches if a search parameter is passed" do
          get :people, filter: "group-#{@group.id}", search: "a st", format: :json
          assigns(:people).should == [@student4]
        end
      end
    end

    describe "pagination" do
      def create_items(num)
        create_list(:student, num)
      end

      def make_request(page=nil)
        if page
          get :people, page: page, format: :json
        else
          get :people, format: :json
        end
      end

      let(:item_list_name){ :people }

      it_behaves_like "a paginated page"
    end
  end

  describe "PUT update_password" do
    let(:user){ create(:teacher_with_user, email: "test@mail.com").user }
    before { user.set_password "pass" }

    shared_examples_for "invalid params" do
      it "does not change the password" do
        make_request
        User.authenticate("test@mail.com", "pass").should == user
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with no current password or new password" do
      let(:make_request){ put :update_password, format: :json }

      it_behaves_like "invalid params"
    end

    context "with no current password" do
      let(:make_request){ put :update_password, user: { new_password: "newpass" }, format: :json }

      it_behaves_like "invalid params"
    end

    context "with no new password" do
      let(:make_request){ put :update_password, user: { current_password: "pass" }, format: :json }

      it_behaves_like "invalid params"
    end

    context "with an invalid current password" do
      let(:make_request){ put :update_password, user: { current_password: "ass", new_password: "newpass" }, format: :json }

      it_behaves_like "invalid params"
    end

    context "with a valid current password" do
      let(:make_request){ put :update_password, user: { current_password: "pass", new_password: "newpass" }, format: :json }

      it "changes the password" do
        make_request
        User.authenticate("test@mail.com", "pass").should be_nil
        User.authenticate("test@mail.com", "newpass").should == user
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end
  end
end