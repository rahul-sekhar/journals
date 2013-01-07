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

end