require 'spec_helper'

describe SubjectTeachersController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Subject
    ability.can :manage, SubjectTeacher
  end


  describe "POST create" do
    let(:subject){ create(:subject) }
    let(:teacher){ create(:teacher) }

    context "with valid data" do
      let(:make_request){ post :create, subject_id: subject.id, subject_teacher: { teacher_id: teacher.id }, format: :json }

      it "raises an exception if the user cannot read the subject" do
        ability.cannot :read, subject
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "raises an exception if the user cannot create a subject teacher" do
        ability.cannot :create, SubjectTeacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a subject teacher with the data passed" do
        expect{ make_request }.to change{ SubjectTeacher.count }.by(1)
      end

      it "creates a subject teacher with the right data" do
        make_request
        assigns(:subject_teacher).subject.should eq(subject)
        assigns(:subject_teacher).teacher.should eq(teacher)
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      before { subject.add_teacher(teacher) }

      let(:make_request){ post :create, subject_id: subject.id, subject_teacher: { teacher_id: teacher.id }, format: :json }

      it "does not create a subject teacher" do
        expect{ make_request }.to change{ SubjectTeacher.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end


  describe "DELETE destroy" do
    let(:subject_teacher){ create(:subject_teacher) }
    let(:make_request){ delete :destroy, format: :json, subject_id: subject_teacher.subject.id, id: subject_teacher.id }

    it "raises an exception if the user cannot read the subject" do
        ability.cannot :read, subject_teacher.subject
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

    it "raises an exception if the user cannot destroy the subject teacher" do
      ability.cannot :destroy, subject_teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct subject teacher" do
      make_request
      assigns(:subject_teacher).should eq(subject_teacher)
    end

    it "destroys the subject teacher" do
      make_request
      assigns(:subject_teacher).should be_destroyed
    end

    it "responds with an 200 status" do
      make_request
      response.status.should eq(200)
      response.body.should be_present
    end
  end



  describe "POST add_student" do
    let(:subject_teacher){ create(:subject_teacher) }
    let(:student){ create(:student, id: 5) }
    before{ student }

    context "with an invalid student_id" do
      let(:make_request){ post :add_student, subject_id: subject_teacher.subject.id, id: subject_teacher.id, student_id: 4, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with a valid student_id" do
      let(:make_request){ post :add_student, subject_id: subject_teacher.subject.id, id: subject_teacher.id, student_id: 5, format: :json }

      it "raises an exception if the user cannot add a student to a subject_teacher" do
        ability.cannot :add_student, subject_teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      context "when the subject_teacher contains that student" do
        before{ subject_teacher.students = [student] }

        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end

        it "leaves the subject_teachers students as is" do
          make_request
          subject_teacher.reload.students.should == [student]
        end
      end

      context "when the subject_teacher does not contain that student" do
        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end

        it "adds the student to the subject_teacher" do
          make_request
          subject_teacher.reload.students.should == [student]
        end
      end
    end
  end


  describe "DELETE remove_student" do
    let(:subject_teacher){ create(:subject_teacher) }
    let(:student){ create(:student, id: 5) }
    before{ student }

    context "with an invalid student_id" do
      let(:make_request){ delete :remove_student, subject_id: subject_teacher.subject.id, id: subject_teacher.id, student_id: 4, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with a valid student_id" do
      let(:make_request){ delete :remove_student, subject_id: subject_teacher.subject.id, id: subject_teacher.id, student_id: 5, format: :json }

      it "raises an exception if the user cannot remove a student to a subject_teacher" do
        ability.cannot :remove_student, subject_teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      context "when the subject_teacher contains that student" do
        before{ subject_teacher.students = [student] }

        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end

        it "removes the student from the subject_teacher" do
          make_request
          subject_teacher.reload.students.should be_empty
        end
      end

      context "when the subject_teacher does not contain that student" do
        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end
      end
    end
  end
end