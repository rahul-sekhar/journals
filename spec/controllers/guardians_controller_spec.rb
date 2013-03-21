require 'spec_helper'

describe GuardiansController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Guardian
  end

  describe "GET all" do
    it "raises an exception if the user cannot view guardians" do
      ability.cannot :read, Guardian
      expect{ get :all, format: :json }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :all, format: :json
      response.status.should == 200
    end

    it "assigns any guardians into a guardians collection" do
      teacher = create(:teacher)
      student = create(:student)
      guardian1 = create(:guardian, students: [create(:student), student])
      guardian2 = create(:guardian, students: [student])
      get :all, format: :json
      assigns(:guardians).should =~ [guardian1, guardian2]
    end
  end

  describe "GET show" do
    let(:student1){ create(:student) }
    let(:student2){ create(:student) }
    let(:guardian){ create(:guardian, students: [student1, student2]) }
    let(:make_request){ get :show, id: guardian.id, format: :json }

    it "raises an exception if the user cannot view the guardian" do
      ability.cannot :read, guardian
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "finds the guardian" do
      make_request
      assigns(:guardian).should eq(guardian)
    end

    it "assigns the found guardian" do
      make_request
      assigns(:guardian).should == guardian
    end

    it "assigns the guardians students" do
      make_request
      assigns(:students).should == [student1, student2]
    end
  end


  describe "POST create" do
    let(:student){ create(:student) }

    context "with valid data" do
      let(:make_request){ post :create, student_id: student.id, guardian: { name: "Rahul Sekhar" }, format: :json }

      it "raises an exception if the user cannot create a guardian" do
        ability.cannot :create, Guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a guardian" do
        expect{ make_request }.to change{ Guardian.count }.by(1)
      end

      it "creates a guardian with the correct name" do
        make_request
        assigns(:guardian).first_name.should == "Rahul"
        assigns(:guardian).last_name.should == "Sekhar"
      end

      it "creates a guardian with the student assigned to it" do
        make_request
        assigns(:guardian).reload.students.should == [student]
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with a guardian id" do
      let(:other_student){ create(:student) }
      let(:guardian){ create(:guardian, students: [other_student]) }
      let(:make_request){ post :create, student_id: student.id, guardian_id: guardian.id, format: :json }

      it "assigns the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "adds the student to that guardian" do
        make_request
        guardian.reload.students.should =~ [student, other_student]
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with an invalid guardian id" do
      let(:make_request){ post :create, student_id: student.id, guardian_id: 7, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with no name" do
      let(:make_request){ post :create, student_id: student.id, guardian: { name: " " }, format: :json }

      it "does not create a guardian" do
        expect{ make_request }.to change{ Guardian.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end



  describe "GET check_duplicates" do
    let(:student){ create(:student) }

    it "raises an exception if the user cannot create a guardian" do
      ability.cannot :create, Guardian
      expect{ get :check_duplicates, student_id: student.id, format: :json }.to raise_exception(CanCan::AccessDenied)
    end

    context "when a name is not passed" do
      let(:make_request){ get :check_duplicates, student_id: student.id, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "when the student already contains a guardian with the same name" do
      let(:make_request){ get :check_duplicates, student_id: student.id, name: "Rahul Sekhar", format: :json }

      before{ create(:guardian, students: [student], name: "Rahul Sekhar") }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "when another student contains a guardian with the same name" do
      let(:make_request){ get :check_duplicates, student_id: student.id, name: "Rahul Sekhar", format: :json }
      let(:other_student){ create(:student) }
      let(:guardian){ create(:guardian, students: [other_student], first_name: "Rahul", last_name: "Sekhar") }
      let(:guardian1){ create(:guardian, first_name: "Rahul", last_name: "Sekhar1") }
      let(:guardian2){ create(:guardian, first_name: "Rahul", last_name: "Sekhar") }
      before do
        guardian
        guardian1
        guardian2
      end

      it "assigns the duplicate guardians" do
        make_request
        assigns(:duplicate_guardians).should =~ [guardian, guardian2]
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end
  end



  describe "PUT update" do
    let(:guardian){ create(:guardian) }

    context "with valid data" do
      let(:make_request){ put :update, id: guardian.id, guardian: { name: "Rahul Sekhar", email: "rahul@mail.com" }, format: :json }

      it "raises an exception if the user cannot update a guardian" do
        ability.cannot :update, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "edits the guardian name" do
        make_request
        assigns(:guardian).reload.name.should == "Rahul Sekhar"
      end

      it "edits the guardian email" do
        make_request
        assigns(:guardian).reload.email.should == "rahul@mail.com"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: guardian.id, guardian: { email: '1234', name: 'Rahul Sekhar' }, format: :json }

      it "does not edit the guardian" do
        make_request
        guardian.reload.name.should_not == "Rahul Sekhar"
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end

      it "returns the error message" do
        make_request
        response.body.should be_present
      end
    end
  end



  describe "DELETE destroy" do
    context "guardian with one student" do
      let(:guardian){ create(:guardian) }
      let(:student){ guardian.students.first }
      let(:make_request){ delete :destroy, id: guardian.id, student_id: student.id, format: :json }

      it "raises an exception if the user cannot destroy a guardian" do
        ability.cannot :destroy, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "destroys the guardian" do
        make_request
        assigns(:guardian).should be_destroyed
      end

      it "removes the guardian from the student" do
        make_request
        student.reload
        student.guardians.should be_empty
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "guardian with multiple students" do
      let(:guardian){ create(:guardian) }
      let(:student){ create(:student) }
      let(:make_request){ delete :destroy, id: guardian.id, student_id: student.id, format: :json }
      before do
        @other_student = guardian.students.first
        guardian.students << student
      end

      it "raises an exception if the user cannot destroy a guardian" do
        ability.cannot :destroy, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "does not destroy the guardian" do
        make_request
        assigns(:guardian).should_not be_destroyed
      end

      it "removes the guardian from the student" do
        make_request
        student.reload
        student.guardians.should be_empty
      end

      it "does not remove the guardian from the other student" do
        make_request
        @other_student.reload
        @other_student.guardians.should == [guardian]
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end
  end



  describe "POST reset" do
    let(:make_request){ post :reset, id: guardian.id, format: :json }

    context "when email is present" do
      let(:guardian){ create(:guardian_with_user) }

      it "raises an exception if the user cannot reset a guardian" do
        ability.cannot :reset, guardian
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct guardian" do
        make_request
        assigns(:guardian).should eq(guardian)
      end

      it "activates the guardian if the guardian is inactive" do
        guardian.should_not be_active
        make_request
        guardian.reload.should be_active
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end

      it "should deliver a user activated mail if the user was inactive" do
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:activation_mail)
        make_request
      end

      it "should deliver a password reset if the user was active" do
        guardian.user.generate_password
        guardian.save!

        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:reset_password_mail)
        make_request
      end
    end

    context "when email is not present" do
      let(:guardian){ create(:guardian) }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        guardian.should_not be_active
        make_request
        guardian.reload.should_not be_active
      end
    end
  end
end