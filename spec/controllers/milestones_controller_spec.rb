require 'spec_helper'

describe MilestonesController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Milestone
  end

  describe "PUT update" do
    let(:milestone){ create(:milestone) }

    context "with valid data" do
      let(:make_request){ put :update, id: milestone.id, milestone: { content: "lorem" }, format: :json }

      it "raises an exception if the user cannot update a milestone" do
        ability.cannot :update, milestone
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct milestone" do
        make_request
        assigns(:milestone).should eq(milestone)
      end

      it "edits the milestone content" do
        make_request
        assigns(:milestone).reload.content.should == "lorem"
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: milestone.id, milestone: { content: "" }, format: :json }

      it "does not edit the milestone" do
        make_request
        milestone.reload.content.should be_present
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "DELETE destroy" do
    let(:milestone){ create(:milestone) }
    let(:make_request){ delete :destroy, format: :json, id: milestone.id }

    it "raises an exception if the user cannot destroy a milestone" do
      ability.cannot :destroy, milestone
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct milestone" do
      make_request
      assigns(:milestone).should eq(milestone)
    end

    it "destroys the milestone" do
      make_request
      assigns(:milestone).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end
end