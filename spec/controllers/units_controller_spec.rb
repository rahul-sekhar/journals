require 'spec_helper'

describe UnitsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Unit
  end

  describe "GET index" do
    it "has a status of 200" do
      get :index, format: :json
      response.status.should eq(200)
    end

    it "finds and assigns units" do
      student = create(:student)
      subject = create(:subject)
      unit1 = create(:unit, student: student, subject: subject)
      unit2 = create(:unit, student: student)
      unit3 = create(:unit, subject: subject)
      unit4 = create(:unit, student: student, subject: subject)
      unit5 = create(:unit)

      get :index, format: :json, student_id: student.id, subject_id: subject.id
      assigns(:units).should =~ [unit1, unit4]
    end
  end


  describe "POST create" do
    let(:student){ create(:student) }
    let(:subject){ create(:subject) }
    context "with valid data" do
      let(:make_request){ post :create, unit: { name: "Something", student_id: student.id, subject_id: subject.id }, format: :json }

      it "raises an exception if the user cannot create a unit" do
        ability.cannot :create, Unit
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a unit with the data passed" do
        expect{ make_request }.to change{ Unit.count }.by(1)
      end

      it "creates a unit with the correct name" do
        make_request
        assigns(:unit).name.should == "Something"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, unit: { name: "", student_id: student.id, subject_id: subject.id }, format: :json }

      it "does not create a unit" do
        expect{ make_request }.to change{ Unit.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "PUT update" do
    let(:unit){ create(:unit) }

    context "with valid data" do
      let(:make_request){ put :update, id: unit.id, unit: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot update a unit" do
        ability.cannot :update, unit
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct unit" do
        make_request
        assigns(:unit).should eq(unit)
      end

      it "edits the unit name" do
        make_request
        assigns(:unit).reload.name.should == "lorem"
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: unit.id, unit: { name: "" }, format: :json }

      it "does not edit the unit" do
        make_request
        unit.reload.name.should be_present
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "DELETE destroy" do
    let(:unit){ create(:unit) }
    let(:make_request){ delete :destroy, format: :json, id: unit.id }

    it "raises an exception if the user cannot destroy a unit" do
      ability.cannot :destroy, unit
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct unit" do
      make_request
      assigns(:unit).should eq(unit)
    end

    it "destroys the unit" do
      make_request
      assigns(:unit).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end
end