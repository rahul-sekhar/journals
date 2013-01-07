require 'spec_helper'

describe StudentsController do
  let(:user){ create(:teacher).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do 
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Student
  end

  describe "GET show" do
    let(:student){ mock_model(Student) }
    before { Student.stub(:find).and_return(student) }

    it "raises an exception if the user cannot view the student" do
      ability.cannot :read, student
      expect{ get :show, id: 5 }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the student given by the passed ID" do
      Student.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found student" do
      get :show, id: 5
      assigns(:student).should == student
    end
  end

  describe "GET edit" do
    let(:student){ create(:student) }
    let(:make_request){ get :edit, id: student.id }

    it "raises an exception if the user cannot update a student" do
      ability.cannot :update, student
      expect{ get :edit, id: student.id }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the student to be edited" do
      make_request
      assigns(:student).should eq(student)
    end

    it "assigns student data from the flash if present" do
      get :edit, { id: student.id }, nil, { student_data: { mobile: "1234" } }
      assigns(:student).mobile.should == "1234"
    end
  end

  describe "PUT update" do
    let(:student){ create(:student) }

    context "with valid data" do
      let(:make_request){ put :update, id: student.id, student: { first_name: "Rahul", last_name: "Sekhar", email: "rahul@mail.com" } }

      it "raises an exception if the user cannot update a student" do
        ability.cannot :update, student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct student" do
        make_request
        assigns(:student).should eq(student)
      end

      it "edits the student name" do
        make_request
        assigns(:student).reload.full_name.should == "Rahul Sekhar"
      end

      it "edits the student email" do
        make_request
        assigns(:student).reload.email.should == "rahul@mail.com"
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: student.id, student: { first_name: "Rahul", last_name: "Sekhar", email: "" } }

      it "does not edit the student" do
        make_request
        student.reload.first_name.should_not == "Rahul"
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_student_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:student_data].should == { 'first_name' => 'Rahul', 'last_name' => 'Sekhar', 'email' => '' }
      end
    end
  end
end