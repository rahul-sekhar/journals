require 'spec_helper'

describe GroupsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Group
  end

  describe "GET index" do
    it "has a status of 200" do
      get :index, format: :json
      response.status.should eq(200)
    end

    it "finds and assigns groups" do
      group1 = create(:group)
      group2 = create(:group)
      get :index, format: :json
      assigns(:groups).should =~ [group1, group2]
    end

    it "orders groups alphabetically" do
      group1 = create(:group, name: "Group A")
      group2 = create(:group, name: "Another Group")
      group3 = create(:group, name: "Group C")
      group4 = create(:group, name: "Another Better Group")
      get :index, format: :json
      assigns(:groups).should == [group4, group2, group1, group3]
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, group: { name: "Something" }, format: :json }

      it "raises an exception if the user cannot create a group" do
        ability.cannot :create, Group
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a group with the data passed" do
        expect{ make_request }.to change{ Group.count }.by(1)
      end

      it "creates a group with the correct name" do
        make_request
        assigns(:group).name.should == "Something"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, group: { name: "" }, format: :json }

      it "does not create a group" do
        expect{ make_request }.to change{ Group.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "PUT update" do
    let(:group){ create(:group) }

    context "with valid data" do
      let(:make_request){ put :update, id: group.id, group: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot update a group" do
        ability.cannot :update, group
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct group" do
        make_request
        assigns(:group).should eq(group)
      end

      it "edits the group name" do
        make_request
        assigns(:group).reload.name.should == "lorem"
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: group.id, group: { name: "" }, format: :json }

      it "does not edit the group" do
        make_request
        group.reload.name.should be_present
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "DELETE destroy" do
    let(:group){ create(:group) }
    let(:make_request){ delete :destroy, format: :json, id: group.id }

    it "raises an exception if the user cannot destroy a group" do
      ability.cannot :destroy, group
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct group" do
      make_request
      assigns(:group).should eq(group)
    end

    it "destroys the group" do
      make_request
      assigns(:group).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end
end