require 'spec_helper'

describe GuardiansController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do 
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Guardian
  end

  describe "GET show" do
    let(:guardian){ mock_model(Guardian) }
    before { Guardian.stub(:find).and_return(guardian) }

    it "raises an exception if the user cannot view the guardian" do
      ability.cannot :read, guardian
      expect{ get :show, id: 5 }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the guardian given by the passed ID" do
      Guardian.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found guardian" do
      get :show, id: 5
      assigns(:guardian).should == guardian
    end
  end

  describe "GET edit" do
    let(:guardian){ create(:guardian) }
    let(:make_request){ get :edit, id: guardian.id }

    it "raises an exception if the user cannot update a guardian" do
      ability.cannot :update, guardian
      expect{ get :edit, id: guardian.id }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the guardian to be edited" do
      make_request
      assigns(:guardian).should eq(guardian)
    end

    it "assigns guardian data from the flash if present" do
      get :edit, { id: guardian.id }, nil, { guardian_data: { mobile: "1234" } }
      assigns(:guardian).mobile.should == "1234"
    end
  end

  describe "PUT update" do
    let(:guardian){ create(:guardian) }

    context "with valid data" do
      let(:make_request){ put :update, id: guardian.id, guardian: { first_name: "Rahul", last_name: "Sekhar", email: "rahul@mail.com" } }

      it "raises an exception if the user cannot update a guardian" do
        ability.cannot :update, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "edits the guardian name" do
        make_request
        assigns(:guardian).reload.full_name.should == "Rahul Sekhar"
      end

      it "edits the guardian email" do
        make_request
        assigns(:guardian).reload.email.should == "rahul@mail.com"
      end

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to guardian_path(guardian)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: guardian.id, guardian: { first_name: "Rahul", last_name: "" } }

      it "does not edit the guardian" do
        make_request
        guardian.reload.first_name.should_not == "Rahul"
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_guardian_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:guardian_data].should == { 'first_name' => 'Rahul', 'last_name' => '' }
      end
    end
  end

  describe "DELETE destroy" do
    context "guardian with one student" do
      let(:guardian){ create(:guardian) }
      let(:student){ guardian.students.first }
      let(:make_request){ delete :destroy, id: guardian.id, student_id: student.id }

      it "raises an exception if the user cannot destroy a guardian" do
        ability.cannot :destroy, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "destroys the guardian" do
        make_request
        assigns(:guardian).should be_destroyed
      end

      it "removes the guardian from the student" do
        make_request
        student.reload
        student.guardians.should be_empty
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

    context "guardian with multiple student" do
      let(:guardian){ create(:guardian) }
      let(:student){ create(:student) }
      let(:make_request){ delete :destroy, id: guardian.id, student_id: student.id }
      before do
        @other_student = guardian.students.first
        guardian.students << student
      end

      it "raises an exception if the user cannot destroy a guardian" do
        ability.cannot :destroy, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "does not destroy the guardian" do
        make_request
        assigns(:guardian).should_not be_destroyed
      end

      it "removes the guardian from the student" do
        make_request
        student.reload
        student.guardians.should be_empty
      end

      it "does not remove the guardian from the other student" do
        make_request
        @other_student.reload
        @other_student.guardians.should == [guardian]
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

  describe "POST reset" do
    let(:make_request){ post :reset, id: guardian.id }

    context "when email is present" do
      let(:guardian){ create(:guardian_with_user) }

      it "raises an exception if the user cannot reset a guardian" do
        ability.cannot :reset, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "activates the guardian if the guardian is inactive" do
        guardian.should_not be_active
        make_request
        guardian.reload.should be_active
      end

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to guardian_path(guardian)
      end

      it "should deliver a user activated mail if the user was inactive" do
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:activation_mail)
        make_request
      end

      it "should deliver a password reset if the user was active" do
        guardian.user.generate_password
        guardian.save!

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
      let(:guardian){ create(:guardian) }

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to guardian_path(guardian)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        guardian.should_not be_active
        make_request
        guardian.reload.should_not be_active
      end

      it "sets a flash error" do
        make_request
        flash[:alert].should be_present
      end
    end
  end
end