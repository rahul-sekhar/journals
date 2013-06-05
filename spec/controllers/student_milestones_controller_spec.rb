require 'spec_helper'

describe StudentMilestonesController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, StudentMilestone
    ability.can :manage, Student
  end

  describe "POST create" do
    let(:student){ create(:student) }
    let(:milestone){ create(:milestone) }

    context "with valid data" do
      let(:make_request){ post :create, student_id: student.id, student_milestone: { status: 1, milestone_id: milestone.id }, format: :json }

      it "raises an exception if the user cannot create a student_milestone" do
        ability.cannot :create, StudentMilestone
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "raises an exception if the user cannot read the student" do
        ability.cannot :read, student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a student_milestone with the data passed" do
        expect{ make_request }.to change{ StudentMilestone.count }.by(1)
      end

      it "creates a student_milestone with the correct status" do
        make_request
        assigns(:student_milestone).status.should == 1
      end

      it "creates a student_milestone with the correct student" do
        make_request
        assigns(:student_milestone).student.should == student
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, student_id: student.id, student_milestone: { status: 4, milestone_id: milestone.id }, format: :json }

      it "does not create a student_milestone" do
        expect{ make_request }.to change{ StudentMilestone.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "PUT update" do
    let(:student_milestone){ create(:student_milestone) }

    context "with valid data" do
      let(:make_request){ put :update, id: student_milestone.id, student_milestone: { status: 2 }, format: :json }

      it "raises an exception if the user cannot update a student_milestone" do
        ability.cannot :update, student_milestone
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct student_milestone" do
        make_request
        assigns(:student_milestone).should eq(student_milestone)
      end

      it "edits the student_milestone status" do
        make_request
        assigns(:student_milestone).reload.status.should == 2
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: student_milestone.id, student_milestone: { status: 4 }, format: :json }

      it "does not edit the student_milestone" do
        make_request
        student_milestone.reload.status.should == 1
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end
end