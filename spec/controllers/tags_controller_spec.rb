require 'spec_helper'

describe TagsController, :focus do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Tag
  end

  describe "GET index" do
    it "has a status of 200" do
      get :index, format: :json
      response.status.should eq(200)
    end

    it "finds and assigns tags" do
      tag1 = create(:tag)
      tag2 = create(:tag)
      get :index, format: :json
      assigns(:tags).should =~ [tag1, tag2]
    end

    it "orders tags alphabetically" do
      tag1 = create(:tag, name: "Group A")
      tag2 = create(:tag, name: "Another Group")
      tag3 = create(:tag, name: "Group C")
      tag4 = create(:tag, name: "Another Better Group")
      get :index, format: :json
      assigns(:tags).should == [tag4, tag2, tag1, tag3]
    end
  end
end