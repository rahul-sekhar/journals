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
      get :home
      response.should redirect_to posts_path
    end
  end


  describe "GET people" do
    it "has a status of 200" do
      get :people, format: :json
      response.status.should == 200
    end

    it "assigns any students and teachers into a people collection" do
      student1 = create(:student)
      student2 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher)
      get :people, format: :json
      assigns(:people).should =~ [student1, student2, teacher1, teacher2]
    end

    it "does not assign archived students and teachers" do
      student1 = create(:student, archived: true)
      student2 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher, archived: true)
      get :people, format: :json
      assigns(:people).should =~ [student2, teacher1]
    end

    it "assigns students and teachers alphabetically" do
      student1 = create(:student, first_name: "Some", last_name: "Student")
      student2 = create(:student, first_name: "Other", last_name: "Student")
      teacher1 = create(:teacher, first_name: "A", last_name: "Teacher")
      teacher2 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      get :people, format: :json
      assigns(:people).should == [teacher1, student2, teacher2, student1]
    end

    it "searches if a search parameter is passed" do
      student1 = create(:student, first_name: "Some", last_name: "Student")
      student2 = create(:student, first_name: "Other", last_name: "Student")
      teacher1 = create(:teacher, first_name: "A", last_name: "Teacher")
      teacher2 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      get :people, search: "ther stu", format: :json
      assigns(:people).should == [student2]
    end

    it "sets an empty_message" do
      get :people, format: :json
      assigns(:empty_message).should be_present
    end
  end


  describe "GET archived" do
    it "has a status of 200" do
      get :archived
      response.status.should == 200
    end

    it "assigns any archived students and teachers into a profiles collection" do
      student1 = create(:student, archived: true)
      student2 = create(:student, archived: true)
      teacher1 = create(:teacher, archived: true)
      teacher2 = create(:teacher, archived: true)
      get :archived
      assigns(:profiles).should =~ [student1, student2, teacher1, teacher2]
    end

    it "does not assign archived students and teachers" do
      student1 = create(:student, archived: true)
      student2 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher, archived: true)
      get :archived
      assigns(:profiles).should =~ [student1, teacher2]
    end

    it "assigns students and teachers alphabetically" do
      student1 = create(:student, archived: true, first_name: "Some", last_name: "Student")
      student2 = create(:student, archived: true, first_name: "Other", last_name: "Student")
      teacher1 = create(:teacher, archived: true, first_name: "A", last_name: "Teacher")
      teacher2 = create(:teacher, archived: true, first_name: "Rahul", last_name: "Sekhar")
      get :archived
      assigns(:profiles).should == [teacher1, student2, teacher2, student1]
    end

    it "searches if a search parameter is passed" do
      student1 = create(:student, archived: true, first_name: "Some", last_name: "Student")
      student2 = create(:student, archived: true, first_name: "Other", last_name: "Student")
      teacher1 = create(:teacher, archived: true, first_name: "A", last_name: "Teacher")
      teacher2 = create(:teacher, archived: true, first_name: "Rahul", last_name: "Sekhar")
      get :archived, search: "ther stu"
      assigns(:profiles).should == [student2]
    end

    it "sets an empty_message" do
      get :archived
      assigns(:empty_message).should be_present
    end
  end


  describe "GET mentees" do
    context "when logged in as a student" do
      before{ user.stub(:profile).and_return(create(:student)) }

      it "raises a page not found exception" do
        expect{ get :mentees }.to raise_exception( ActiveRecord::RecordNotFound )
      end
    end

    context "when logged in as a guardian" do
      before{ user.stub(:profile).and_return(create(:guardian)) }

      it "raises a page not found exception" do
        expect{ get :mentees }.to raise_exception( ActiveRecord::RecordNotFound )
      end
    end

    context "when logged in as a teacher" do
      let(:teacher){ create(:teacher) }
      before{ user.stub(:profile).and_return(teacher) }

      it "has a status of 200" do
        get :mentees
        response.status.should == 200
      end

      it "assigns any mentees into a profiles collection" do
        student1 = create(:student)
        student2 = create(:student)
        student3 = create(:student)
        teacher.mentees = [student1, student3]
        get :mentees
        assigns(:profiles).should =~ [student1, student3]
      end

      it "assigns mentees alphabetically" do
        student1 = create(:student, first_name: "Some", last_name: "Student")
        student2 = create(:student, first_name: "Other", last_name: "Student")
        student3 = create(:student, first_name: "A", last_name: "Student")
        teacher.mentees = [student1, student2, student3]
        get :mentees
        assigns(:profiles).should == [student3, student2, student1]
      end

      it "searches if a search parameter is passed" do
        student1 = create(:student, first_name: "Some", last_name: "Student")
        student2 = create(:student, first_name: "Other", last_name: "Student")
        student3 = create(:student, first_name: "A", last_name: "Student")
        teacher.mentees = [student1, student2, student3]
        get :mentees, search: "oth"
        assigns(:profiles).should == [student2]
      end

      it "sets an empty_message" do
        get :mentees
        assigns(:empty_message).should be_present
      end
    end
  end



  describe "GET change_password" do
    it "has a 200 status" do
      get :change_password
      response.status.should eq(200)
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

      it "sets an alert" do
        make_request
        flash[:alert].should be_present
      end

      it "redirects to the change password page" do
        make_request
        response.should redirect_to change_password_path
      end
    end

    context "with no current password or new password" do
      let(:make_request){ put :update_password }

      it_behaves_like "invalid params"
    end

    context "with no current password" do
      let(:make_request){ put :update_password, user: { new_password: "newpass" } }

      it_behaves_like "invalid params"
    end

    context "with no new password" do
      let(:make_request){ put :update_password, user: { current_password: "pass" } }

      it_behaves_like "invalid params"
    end

    context "with an invalid current password" do
      let(:make_request){ put :update_password, user: { current_password: "ass", new_password: "newpass" } }

      it_behaves_like "invalid params"
    end

    context "with a valid current password" do
      let(:make_request){ put :update_password, user: { current_password: "pass", new_password: "newpass" } }

      it "changes the password" do
        make_request
        User.authenticate("test@mail.com", "pass").should be_nil
        User.authenticate("test@mail.com", "newpass").should == user
      end

      it "sets an notice" do
        make_request
        flash[:notice].should be_present
      end

      it "redirects to the posts page" do
        make_request
        response.should redirect_to posts_path
      end
    end
  end
end