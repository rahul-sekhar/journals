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

  describe "GET show" do
    let(:group){ create(:group) }
    let(:make_request) { get :show, id: group.id }

    before do
      @student1 = create(:student)
      @student2 = create(:student)
      @student3 = create(:student)
      group.students = [@student1, @student3]
    end

    it "raises an exception if the user cannot read the group" do
      ability.cannot :read, group
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the found groups students" do
      make_request
      assigns(:profiles).should =~ [@student1, @student3]
    end

    it "sets an empty_message" do
      make_request
      assigns(:empty_message).should be_present
    end
  end


  describe "GET index" do
    it "raises an exception if the user cannot manage groups" do
      ability.cannot :manage, Group
      expect{ get :index }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :index
      response.status.should eq(200)
    end

    it "finds and assigns groups" do
      group1 = create(:group)
      group2 = create(:group)
      get :index
      assigns(:groups).should =~ [group1, group2]
    end

    it "orders groups alphabetically" do
      group1 = create(:group, name: "Group A")
      group2 = create(:group, name: "Another Group")
      group3 = create(:group, name: "Group C")
      group4 = create(:group, name: "Another Better Group")
      get :index
      assigns(:groups).should == [group4, group2, group1, group3]
    end
  end


  describe "GET new" do
    it "raises an exception if the user cannot create a group" do
      ability.cannot :create, Group
      expect{ get :new }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :new
      response.status.should eq(200)
    end

    it "assigns a new group" do
      get :new
      assigns(:group).should be_a Group
      assigns(:group).should be_new_record
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, group: { name: "Something" } }

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

      it "redirects to the people page" do
        make_request
        response.should redirect_to people_path
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, group: { name: "" } }

      it "does not create a group" do
        expect{ make_request }.to change{ Group.count }.by(0)
      end
      
      it "redirects to the new page" do
        make_request
        response.should redirect_to new_group_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end
    end
  end



  describe "GET edit" do
    let(:group){ create(:group) }
    let(:make_request){ get :edit, id: group.id }

    it "raises an exception if the user cannot update a group" do
      ability.cannot :update, group
      expect{ get :edit, id: group.id }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the group to be edited" do
      make_request
      assigns(:group).should eq(group)
    end
  end


  describe "PUT update" do
    let(:group){ create(:group) }

    context "with valid data" do
      let(:make_request){ put :update, id: group.id, group: { name: "lorem" } }

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

      it "redirects to the groups page" do
        make_request
        response.should redirect_to groups_path
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: group.id, group: { name: "" } }

      it "does not edit the group" do
        make_request
        group.reload.name.should be_present
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_group_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end
    end
  end


  describe "DELETE destroy" do
    let(:group){ create(:group) }
    let(:make_request){ delete :destroy, id: group.id }

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

    it "redirects to the groups page" do
      make_request
      response.should redirect_to groups_path
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end
end