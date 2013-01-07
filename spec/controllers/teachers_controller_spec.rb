require 'spec_helper'

describe TeachersController do
  let(:user){ create(:teacher).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do 
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Teacher
  end

  describe "GET show" do
    let(:teacher){ mock_model(Teacher) }
    before { Teacher.stub(:find).and_return(teacher) }

    it "raises an exception if the user cannot view the teacher" do
      ability.cannot :read, teacher
      expect{ get :show, id: 5 }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the teacher given by the passed ID" do
      Teacher.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found teacher" do
      get :show, id: 5
      assigns(:teacher).should == teacher
    end
  end

  describe "GET edit" do
    let(:teacher){ create(:teacher) }
    let(:make_request){ get :edit, id: teacher.id }

    it "raises an exception if the user cannot update a teacher" do
      ability.cannot :update, teacher
      expect{ get :edit, id: teacher.id }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the teacher to be edited" do
      make_request
      assigns(:teacher).should eq(teacher)
    end

    it "assigns teacher data from the flash if present" do
      get :edit, { id: teacher.id }, nil, { teacher_data: { mobile: "1234" } }
      assigns(:teacher).mobile.should == "1234"
    end
  end

  describe "PUT update" do
    let(:teacher){ create(:teacher) }

    context "with valid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { first_name: "Rahul", last_name: "Sekhar", email: "rahul@mail.com" } }

      it "raises an exception if the user cannot update a teacher" do
        ability.cannot :update, teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct teacher" do
        make_request
        assigns(:teacher).should eq(teacher)
      end

      it "edits the teacher name" do
        make_request
        assigns(:teacher).reload.full_name.should == "Rahul Sekhar"
      end

      it "edits the teacher email" do
        make_request
        assigns(:teacher).reload.email.should == "rahul@mail.com"
      end

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { first_name: "Rahul", last_name: "Sekhar", email: "" } }

      it "does not edit the teacher" do
        make_request
        teacher.reload.first_name.should_not == "Rahul"
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_teacher_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:teacher_data].should == { 'first_name' => 'Rahul', 'last_name' => 'Sekhar', 'email' => '' }
      end
    end
  end
end