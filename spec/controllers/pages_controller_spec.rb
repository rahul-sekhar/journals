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
      get :people
      response.status.should == 200
    end

    it "assigns any students and teachers into a profiles collection" do
      student1 = create(:student)
      student2 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher)
      get :people
      assigns(:profiles).should =~ [student1, student2, teacher1, teacher2]
    end

    it "does not assign archived students and teachers" do
      student1 = create(:student, archived: true)
      student2 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher, archived: true)
      get :people
      assigns(:profiles).should =~ [student2, teacher1]
    end

    it "assigns students and teachers alphabetically" do
      student1 = create(:student, first_name: "Some", last_name: "Student")
      student2 = create(:student, first_name: "Other", last_name: "Student")
      teacher1 = create(:teacher, first_name: "A", last_name: "Teacher")
      teacher2 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      get :people
      assigns(:profiles).should == [teacher1, student2, teacher2, student1]
    end

    it "sets an empty_message" do
      get :people
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

    it "sets an empty_message" do
      get :archived
      assigns(:empty_message).should be_present
    end
  end
end