require 'spec_helper'

describe StudentsController do
  let(:user){ create(:teacher_with_user).user }
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
      let(:make_request){ put :update, id: student.id, student: { first_name: "Rahul", last_name: "" } }

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
        flash[:student_data].should == { 'first_name' => 'Rahul', 'last_name' => '' }
      end
    end
  end

  describe "DELETE destroy" do
    let(:student){ create(:student) }
    let(:make_request){ delete :destroy, id: student.id }

    it "raises an exception if the user cannot destroy a student" do
      ability.cannot :destroy, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct student" do
      make_request
      assigns(:student).should eq(student)
    end

    it "destroys the student" do
      make_request
      assigns(:student).should be_destroyed
    end

    it "redirects to the people page" do
      make_request
      response.should redirect_to people_path
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end

  describe "POST reset" do
    let(:make_request){ post :reset, id: student.id }

    context "when email is present" do
      let(:student){ create(:student_with_user) }

      it "raises an exception if the user cannot reset a student" do
        ability.cannot :reset, student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct student" do
        make_request
        assigns(:student).should eq(student)
      end

      it "activates the student if the student is inactive" do
        student.should_not be_active
        make_request
        student.reload.should be_active
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "should deliver a user activated mail if the user was inactive" do
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:activation_mail)
        make_request
      end

      it "should deliver a password reset if the user was active" do
        student.reset_password
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:reset_password_mail)
        make_request
      end

      it "sets a flash message" do
        make_request
        flash[:notice].should be_present
      end
    end

    context "when email is not present" do
      let(:student){ create(:student) }

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        make_request
        student.reload.should_not be_active
      end

      it "sets a flash error" do
        make_request
        flash[:alert].should be_present
      end
    end
  end

  describe "POST archive" do
    let(:student){ create(:student) }
    let(:make_request){ post :archive, id: student.id }

    it "raises an exception if the user cannot archive a student" do
      ability.cannot :archive, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct student" do
      make_request
      assigns(:student).should eq(student)
    end

    it "toggles the students archived state" do
      Student.stub(:find).and_return(student)
      student.should_receive(:toggle_archive)
      make_request
    end

    it "redirects to the student page" do
      make_request
      response.should redirect_to student_path(student)
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end
end