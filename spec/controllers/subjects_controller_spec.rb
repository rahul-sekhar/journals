require 'spec_helper'

describe SubjectsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Subject
  end

  describe "GET index" do
    let(:make_request){ get :index, format: :json }

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "raises an exception if the user cannot read subjects" do
      ability.cannot :read, Subject
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds and assigns subjects" do
      subject1 = create(:subject)
      subject2 = create(:subject)
      make_request
      assigns(:subjects).should match_array [subject1, subject2]
    end

    it "orders subjects alphabetically" do
      subject1 = create(:subject, name: "Subject A")
      subject2 = create(:subject, name: "Another Subject")
      subject3 = create(:subject, name: "Subject C")
      subject4 = create(:subject, name: "Another Better Subject")
      make_request
      assigns(:subjects).should == [subject4, subject2, subject1, subject3]
    end
  end


  describe "GET for_student" do
    before do
      ability.can :manage, Student
      Student.any_instance.stub(:subjects).and_return('some subjects')
    end

    let(:student){ create(:student) }
    let(:make_request){ get :for_student, student_id: student.id, format: :json }

    it "raises an exception if the user cannot read subjects" do
      ability.cannot :read, Subject
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "raises an exception if the user cannot get subjects for the student" do
      ability.cannot :view_academics, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "finds and assigns the student" do
      make_request
      assigns(:student).should eq(student)
    end

    it "finds and assigns the students subjects" do
      make_request
      assigns(:subjects).should == 'some subjects'
    end
  end


  describe "GET show" do
    let(:subject){ mock_model(Subject) }
    before { Subject.stub(:find).and_return(subject) }

    describe "without a student_id" do
      let(:make_request) { get :show, id: 5, format: :json }

      it "raises an exception if the user cannot read the subject" do
        ability.cannot :read, subject
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end

      it "finds the subject given by the passed ID" do
        Subject.should_receive(:find).with("5")
        make_request
      end

      it "assigns the found subject" do
        make_request
        assigns(:subject).should == subject
      end
    end

    describe "with a student id" do
      let(:student){ mock_model(Student) }
      before { Student.stub(:find).and_return(student) }
      let(:make_request) { get :show, id: 5, student_id: 10, format: :json }

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end

      it "finds the student given by the passed ID" do
        Student.should_receive(:find).with(10)
        make_request
      end

      it "assigns the found student" do
        make_request
        assigns(:student).should == student
      end
    end
  end


  describe "GET people" do
    let(:subject){ mock_model(Subject) }
    before { Subject.stub(:find).and_return(subject) }
    let(:make_request) { get :people, id: 5, format: :json }

    it "raises an exception if the user cannot read the subject" do
      ability.cannot :read, subject
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "finds the subject given by the passed ID" do
      Subject.should_receive(:find).with("5")
      make_request
    end

    it "assigns the found subject" do
      make_request
      assigns(:subject).should == subject
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, subject: { name: "Something" }, format: :json }

      it "raises an exception if the user cannot create a subject" do
        ability.cannot :create, Subject
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a subject with the data passed" do
        expect{ make_request }.to change{ Subject.count }.by(1)
      end

      it "creates a subject with the correct name" do
        make_request
        assigns(:subject).name.should == "Something"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, subject: { name: "" }, format: :json }

      it "does not create a subject" do
        expect{ make_request }.to change{ Subject.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "PUT update" do
    let(:subject){ create(:subject) }

    context "with valid data" do
      let(:make_request){ put :update, id: subject.id, subject: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot update a subject" do
        ability.cannot :update, subject
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct subject" do
        make_request
        assigns(:subject).should eq(subject)
      end

      it "edits the subject name" do
        make_request
        assigns(:subject).reload.name.should == "lorem"
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: subject.id, subject: { name: "" }, format: :json }

      it "does not edit the subject" do
        make_request
        subject.reload.name.should be_present
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "DELETE destroy" do
    let(:subject){ create(:subject) }
    let(:make_request){ delete :destroy, format: :json, id: subject.id }

    it "raises an exception if the user cannot destroy a subject" do
      ability.cannot :destroy, subject
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct subject" do
      make_request
      assigns(:subject).should eq(subject)
    end

    it "destroys the subject" do
      make_request
      assigns(:subject).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end


  describe "POST add_strand" do
    let(:subject){ create(:subject) }

    before do
      ability.can :manage, Strand
    end

    context "with valid data" do
      let(:make_request){ post :add_strand, id: subject.id, strand: { name: "lorem" }, format: :json }

      it "raises an exception if the user cannot add a strand" do
        ability.cannot :create, Strand
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "adds the strand" do
        expect{ make_request }.to change{ Strand.count }.by(1)
      end

      it "adds the strand with the correct data" do
        make_request
        subject.reload.strands.first.name.should eq("lorem")
      end

      it "responds with a 200 status" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :add_strand, id: subject.id, strand: { name: "" }, format: :json }

      it "does not add the strand" do
        expect{ make_request }.to change{ Strand.count }.by(0)
      end

      it "responds with a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end
end