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

end