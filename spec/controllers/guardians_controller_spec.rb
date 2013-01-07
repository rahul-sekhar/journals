require 'spec_helper'

describe GuardiansController do
  let(:user){ create(:teacher).user }
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
end