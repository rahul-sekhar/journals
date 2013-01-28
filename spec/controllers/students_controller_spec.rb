require 'spec_helper'

describe StudentsController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do 
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Student
  end

  describe "GET index" do
    it "raises an exception if the user cannot view students" do
      ability.cannot :read, Student
      expect{ get :index }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :index
      response.status.should == 200
    end

    it "assigns any students into a profiles collection" do
      teacher1 = create(:teacher)
      student1 = create(:student)
      student2 = create(:student)
      get :index
      assigns(:profiles).should =~ [student1, student2]
    end

    it "does not assign archived students" do
      student1 = create(:student)
      student2 = create(:student, archived: true)
      get :index
      assigns(:profiles).should == [student1]
    end

    it "sorts the students alphabetically" do
      student1 = create(:student, first_name: "Rahul", last_name: "Sekhar")
      student2 = create(:student, first_name: "Ze", last_name: "Student")
      student3 = create(:student, first_name: "A", last_name: "Student")
      get :index
      assigns(:profiles).should == [student3, student1, student2]
    end

    it "searches for students when the search parameter is passed" do
      student1 = create(:student, first_name: "Rahul", last_name: "Sekhar")
      student2 = create(:student, first_name: "Ze", last_name: "Student")
      student3 = create(:student, first_name: "A", last_name: "Student")
      get :index, search: "student"
      assigns(:profiles).should =~ [student3, student2]
    end

    it "sets an empty_message" do
      get :index
      assigns(:empty_message).should be_present
    end
  end



  describe "GET show" do
    let(:student){ mock_model(Student) }
    before { Student.stub(:find).and_return(student) }

    it "raises an exception if the user cannot view the student" do
      ability.cannot :read, student
      expect{ get :show, id: 5 }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the student given by the passed ID" do
      Student.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found student" do
      get :show, id: 5
      assigns(:student).should == student
    end
  end



  describe "GET new" do
    let(:make_request){ get :new }

    it "raises an exception if the user cannot create a student" do
      ability.cannot :create, Student
      expect{ get :new }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns an empty student" do
      make_request
      assigns(:student).should be_new_record
    end

    it "assigns student data from the flash if present" do
      get :new, nil, nil, { student_data: { mobile: "1234" } }
      assigns(:student).mobile.should == "1234"
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, student: { first_name: "Rahul", last_name: "Sekhar" } }

      it "raises an exception if the user cannot create a student" do
        ability.cannot :create, Student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a student" do
        expect{ make_request }.to change{ Student.count }.by(1)
      end

      it "creates a student with the correct name" do
        make_request
        assigns(:student).first_name.should == "Rahul"
        assigns(:student).last_name.should == "Sekhar"
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(assigns(:student))
      end
    end

    context "with only a first name" do
      let(:make_request){ post :create, student: { first_name: "Rahul", last_name: " " } }

      it "creates a student" do
        expect{ make_request }.to change{ Student.count }.by(1)
      end

      it "sets the last name and not the first name" do
        make_request
        assigns(:student).first_name.should be_nil
        assigns(:student).last_name.should == "Rahul"
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(assigns(:student))
      end
    end

    context "with no first name or last name" do
      let(:make_request){ post :create, student: { first_name: " " } }

      it "does not create a student" do
        expect{ make_request }.to change{ Teacher.count }.by(0)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end

      it "redirects to the new student page" do
        make_request
        response.should redirect_to new_student_path
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:student_data].should == { 'first_name' => ' ' }
      end
    end
  end


  describe "GET edit" do
    let(:student){ create(:student) }
    let(:make_request){ get :edit, id: student.id }

    it "raises an exception if the user cannot update a student" do
      ability.cannot :update, student
      expect{ get :edit, id: student.id }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the student to be edited" do
      make_request
      assigns(:student).should eq(student)
    end

    it "assigns student data from the flash if present" do
      get :edit, { id: student.id }, nil, { student_data: { mobile: "1234" } }
      assigns(:student).mobile.should == "1234"
    end
  end



  describe "PUT update" do
    let(:student){ create(:student) }

    context "with valid data" do
      let(:make_request){ put :update, id: student.id, student: { first_name: "Rahul", last_name: "Sekhar", email: "rahul@mail.com" } }

      it "raises an exception if the user cannot update a student" do
        ability.cannot :update, student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct student" do
        make_request
        assigns(:student).should eq(student)
      end

      it "edits the student name" do
        make_request
        assigns(:student).reload.full_name.should == "Rahul Sekhar"
      end

      it "edits the student email" do
        make_request
        assigns(:student).reload.email.should == "rahul@mail.com"
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: student.id, student: { first_name: "", last_name: "", mobile: '1234' } }

      it "does not edit the student" do
        make_request
        student.reload.first_name.should_not == "Rahul"
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_student_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:student_data].should == { 'first_name' => '', 'last_name' => '', 'mobile' => '1234' }
      end
    end
  end



  describe "DELETE destroy" do
    let(:student){ create(:student) }
    let(:make_request){ delete :destroy, id: student.id }

    it "raises an exception if the user cannot destroy a student" do
      ability.cannot :destroy, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct student" do
      make_request
      assigns(:student).should eq(student)
    end

    it "destroys the student" do
      make_request
      assigns(:student).should be_destroyed
    end

    it "redirects to the people page" do
      make_request
      response.should redirect_to people_path
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end



  describe "POST reset" do
    let(:make_request){ post :reset, id: student.id }

    context "when email is present" do
      let(:student){ create(:student_with_user) }

      it "raises an exception if the user cannot reset a student" do
        ability.cannot :reset, student
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct student" do
        make_request
        assigns(:student).should eq(student)
      end

      it "activates the student if the student is inactive" do
        student.should_not be_active
        make_request
        student.reload.should be_active
      end

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "should deliver a user activated mail if the user was inactive" do
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:activation_mail)
        make_request
      end

      it "should deliver a password reset if the user was active" do
        student.reset_password
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:reset_password_mail)
        make_request
      end

      it "sets a flash message" do
        make_request
        flash[:notice].should be_present
      end
    end

    context "when email is not present" do
      let(:student){ create(:student) }

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        make_request
        student.reload.should_not be_active
      end

      it "sets a flash error" do
        make_request
        flash[:alert].should be_present
      end
    end
  end



  describe "POST archive" do
    let(:student){ create(:student) }
    let(:make_request){ post :archive, id: student.id }

    it "raises an exception if the user cannot archive a student" do
      ability.cannot :archive, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct student" do
      make_request
      assigns(:student).should eq(student)
    end

    it "toggles the students archived state" do
      Student.stub(:find).and_return(student)
      student.should_receive(:toggle_archive)
      make_request
    end

    it "redirects to the student page" do
      make_request
      response.should redirect_to student_path(student)
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end



  describe "POST add_group" do
    let(:student){ create(:student) }
    let(:group){ create(:group, id: 5) }
    let(:make_request){ post :add_group, id: student.id  }
    before{ group }

    it "raises an exception if the user cannot add a group to a student" do
      ability.cannot :add_group, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a group_id" do
      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid group_id" do
      let(:make_request){ post :add_group, id: student.id, group_id: 4 }

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid group_id" do
      let(:make_request){ post :add_group, id: student.id, group_id: 5 }

      context "when the student contains that group" do
        before{ student.groups = [group] }

        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "sets a flash alert" do
          make_request
          flash[:alert].should be_present
        end
      end

      context "when the student does not contain that group" do
        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "adds the group to the student" do
          make_request
          student.reload.groups.should == [group]
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end



  describe "POST remove_group" do
    let(:student){ create(:student) }
    let(:group){ create(:group, id: 5) }
    let(:make_request){ post :remove_group, id: student.id  }
    before{ group }

    it "raises an exception if the user cannot remove a group to a student" do
      ability.cannot :remove_group, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a group_id" do
      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid group_id" do
      let(:make_request){ post :remove_group, id: student.id, group_id: 4 }

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid group_id" do
      let(:make_request){ post :remove_group, id: student.id, group_id: 5 }

      context "when the student contains that group" do
        before{ student.groups = [group] }

        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "removes the group from the student" do
          make_request
          student.reload.groups.should be_empty
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end

      context "when the student does not contain that group" do
        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end


  describe "POST add_mentor" do
    let(:student){ create(:student) }
    let(:teacher){ create(:teacher, id: 5) }
    let(:make_request){ post :add_mentor, id: student.id  }
    before{ teacher }

    it "raises an exception if the user cannot add a teacher to a student" do
      ability.cannot :add_mentor, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a teacher_id" do
      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid teacher_id" do
      let(:make_request){ post :add_mentor, id: student.id, teacher_id: 4 }

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid teacher_id" do
      let(:make_request){ post :add_mentor, id: student.id, teacher_id: 5 }

      context "when the student contains that teacher" do
        before{ student.mentors = [teacher] }

        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "sets a flash alert" do
          make_request
          flash[:alert].should be_present
        end
      end

      context "when the student does not contain that teacher" do
        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "adds the teacher to the student" do
          make_request
          student.reload.mentors.should == [teacher]
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end


  describe "POST remove_mentor" do
    let(:student){ create(:student) }
    let(:teacher){ create(:teacher, id: 5) }
    let(:make_request){ post :remove_mentor, id: student.id  }
    before{ teacher }

    it "raises an exception if the user cannot remove a teacher to a student" do
      ability.cannot :remove_mentor, student
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a teacher_id" do
      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid teacher_id" do
      let(:make_request){ post :remove_mentor, id: student.id, teacher_id: 4 }

      it "redirects to the student page" do
        make_request
        response.should redirect_to student_path(student)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid teacher_id" do
      let(:make_request){ post :remove_mentor, id: student.id, teacher_id: 5 }

      context "when the student contains that teacher" do
        before{ student.mentors = [teacher] }

        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "removes the teacher from the student" do
          make_request
          student.reload.mentors.should be_empty
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end

      context "when the student does not contain that teacher" do
        it "redirects to the student page" do
          make_request
          response.should redirect_to student_path(student)
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end
end