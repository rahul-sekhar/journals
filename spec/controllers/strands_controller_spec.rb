require 'spec_helper'

describe StrandsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Strand
  end

  describe "POST add_milestone" do
    let(:strand){ create(:strand) }

    before do
      ability.can :manage, Milestone
    end

    context "with valid data" do
      let(:make_request){ post :add_milestone, id: strand.id, milestone: { content: "lorem", level: 4 }, format: :json }

      it "raises an exception if the user cannot add a milestone" do
        ability.cannot :create, Milestone
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "adds the milestone" do
        expect{ make_request }.to change{ Milestone.count }.by(1)
      end

      it "adds the milestone with the correct data" do
        make_request
        milestone = strand.milestones.first
        milestone.level.should eq(4)
        milestone.content.should eq("lorem")
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :add_milestone, id: strand.id, milestone: { content: "lorem" }, format: :json }

      it "does not add the milestone" do
        expect{ make_request }.to change{ Milestone.count }.by(0)
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end



  describe "POST add_strand" do
    let(:strand){ create(:strand) }
    before { strand }

    context "with valid data" do
      let(:make_request){ post :add_strand, id: strand.id, strand: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot add a strand" do
        ability.cannot :create, Strand
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "adds the strand" do
        expect{ make_request }.to change{ Strand.count }.by(1)
      end

      it "adds the strand with the correct data" do
        make_request
        strand.reload.child_strands.first.name.should eq("lorem")
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :add_strand, id: strand.id, strand: { name: "" }, format: :json }

      it "does not add the strand" do
        expect{ make_request }.to change{ Strand.count }.by(0)
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "PUT update" do
    let(:strand){ create(:strand) }

    context "with valid data" do
      let(:make_request){ put :update, id: strand.id, strand: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot update a strand" do
        ability.cannot :update, strand
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct strand" do
        make_request
        assigns(:strand).should eq(strand)
      end

      it "edits the strand name" do
        make_request
        assigns(:strand).reload.name.should == "lorem"
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: strand.id, strand: { name: "" }, format: :json }

      it "does not edit the strand" do
        make_request
        strand.reload.name.should be_present
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "DELETE destroy" do
    let(:strand){ create(:strand) }
    let(:make_request){ delete :destroy, format: :json, id: strand.id }

    it "raises an exception if the user cannot destroy a strand" do
      ability.cannot :destroy, strand
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct strand" do
      make_request
      assigns(:strand).should eq(strand)
    end

    it "destroys the strand" do
      make_request
      assigns(:strand).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end
end