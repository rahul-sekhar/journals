require 'spec_helper'

describe TeachersController do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do 
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Teacher
  end


  describe "GET index" do
    let(:user){ create(:student_with_user).user }

    it "raises an exception if the user cannot view teachers" do
      ability.cannot :read, Teacher
      expect{ get :index }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :index
      response.status.should == 200
    end

    it "assigns any teachers into a profiles collection" do
      student1 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher)
      get :index
      assigns(:profiles).should =~ [teacher1, teacher2]
    end

    it "does not assign archived teachers" do
      teacher1 = create(:teacher)
      teacher2 = create(:teacher, archived: true)
      get :index
      assigns(:profiles).should == [teacher1]
    end

    it "sorts the teachers alphabetically" do
      teacher1 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      teacher2 = create(:teacher, first_name: "Ze", last_name: "Teacher")
      teacher3 = create(:teacher, first_name: "A", last_name: "Teacher")
      get :index
      assigns(:profiles).should == [teacher3, teacher1, teacher2]
    end

    it "sets an empty_message" do
      get :index
      assigns(:empty_message).should be_present
    end
  end


  describe "GET show" do
    let(:teacher){ mock_model(Teacher) }
    before { Teacher.stub(:find).and_return(teacher) }

    it "raises an exception if the user cannot view the teacher" do
      ability.cannot :read, teacher
      expect{ get :show, id: 5 }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5
      response.status.should eq(200)
    end

    it "finds the teacher given by the passed ID" do
      Teacher.should_receive(:find).with("5")
      get :show, id: 5
    end

    it "assigns the found teacher" do
      get :show, id: 5
      assigns(:teacher).should == teacher
    end
  end


  describe "GET new" do
    let(:make_request){ get :new }

    it "raises an exception if the user cannot create a teacher" do
      ability.cannot :create, Teacher
      expect{ get :new }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns an empty teacher" do
      make_request
      assigns(:teacher).should be_new_record
    end
  end


  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, teacher: { first_name: "Rahul", last_name: "Sekhar" } }

      it "raises an exception if the user cannot create a teacher" do
        ability.cannot :create, Teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a teacher" do
        expect{ make_request }.to change{ Teacher.count }.by(1)
      end

      it "creates a teacher with the correct name" do
        make_request
        assigns(:teacher).first_name.should == "Rahul"
        assigns(:teacher).last_name.should == "Sekhar"
      end

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(assigns(:teacher))
      end
    end

    context "with only a first name" do
      let(:make_request){ post :create, teacher: { first_name: "Rahul", last_name: " " } }

      it "creates a teacher" do
        expect{ make_request }.to change{ Teacher.count }.by(1)
      end

      it "sets the last name and not the first name" do
        make_request
        assigns(:teacher).first_name.should be_nil
        assigns(:teacher).last_name.should == "Rahul"
      end

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(assigns(:teacher))
      end
    end

    context "with no first name or last name" do
      let(:make_request){ post :create, teacher: { first_name: " " } }

      it "does not create a teacher" do
        expect{ make_request }.to change{ Teacher.count }.by(0)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end

      it "redirects to the new teacher page" do
        make_request
        response.should redirect_to new_teacher_path
      end
    end
  end


  describe "GET edit" do
    let(:teacher){ create(:teacher) }
    let(:make_request){ get :edit, id: teacher.id }

    it "raises an exception if the user cannot update a teacher" do
      ability.cannot :update, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the teacher to be edited" do
      make_request
      assigns(:teacher).should eq(teacher)
    end

    it "assigns teacher data from the flash if present" do
      get :edit, { id: teacher.id }, nil, { teacher_data: { mobile: "1234" } }
      assigns(:teacher).mobile.should == "1234"
    end
  end


  describe "PUT update" do
    let(:teacher){ create(:teacher) }

    context "with valid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { first_name: "Rahul", last_name: "Sekhar", email: "rahul@mail.com" } }

      it "raises an exception if the user cannot update a teacher" do
        ability.cannot :update, teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct teacher" do
        make_request
        assigns(:teacher).should eq(teacher)
      end

      it "edits the teacher name" do
        make_request
        assigns(:teacher).reload.full_name.should == "Rahul Sekhar"
      end

      it "edits the teacher email" do
        make_request
        assigns(:teacher).reload.email.should == "rahul@mail.com"
      end

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { first_name: "", last_name: "" } }

      it "does not edit the teacher" do
        make_request
        teacher.reload.first_name.should_not == "Rahul"
      end
      
      it "redirects to the edit page" do
        make_request
        response.should redirect_to edit_teacher_path
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should be_present
      end

      it "stores already filled data in a flash object" do
        make_request
        flash[:teacher_data].should == { 'first_name' => '', 'last_name' => '' }
      end
    end
  end


  describe "DELETE destroy" do
    let(:teacher){ create(:teacher) }
    let(:make_request){ delete :destroy, id: teacher.id }

    it "raises an exception if the user cannot destroy a teacher" do
      ability.cannot :destroy, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct teacher" do
      make_request
      assigns(:teacher).should eq(teacher)
    end

    it "destroys the teacher" do
      make_request
      assigns(:teacher).should be_destroyed
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
    let(:make_request){ post :reset, id: teacher.id }

    context "when email is present" do
      let(:teacher){ create(:teacher_with_user) }

      it "raises an exception if the user cannot reset a teacher" do
        ability.cannot :reset, teacher
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct teacher" do
        make_request
        assigns(:teacher).should eq(teacher)
      end

      it "activates the teacher if the teacher is inactive" do
        teacher.should_not be_active
        make_request
        teacher.reload.should be_active
      end

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "should deliver a user activated mail if the user was inactive" do
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:activation_mail)
        make_request
      end

      it "should deliver a password reset if the user was active" do
        teacher.reset_password
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
      let(:teacher){ create(:teacher) }

      it "redirects to the guardian page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        make_request
        teacher.reload.should_not be_active
      end

      it "sets a flash error" do
        make_request
        flash[:alert].should be_present
      end
    end
  end


  describe "POST archive" do
    let(:teacher){ create(:teacher) }
    let(:make_request){ post :archive, id: teacher.id }

    it "raises an exception if the user cannot archive a teacher" do
      ability.cannot :archive, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct teacher" do
      make_request
      assigns(:teacher).should eq(teacher)
    end

    it "toggles the teachers archived state" do
      Teacher.stub(:find).and_return(teacher)
      teacher.should_receive(:toggle_archive)
      make_request
    end

    it "redirects to the teacher page" do
      make_request
      response.should redirect_to teacher_path(teacher)
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should be_present
    end
  end


  describe "POST add_mentee" do
    let(:teacher){ create(:teacher) }
    let(:student){ create(:student, id: 5) }
    let(:make_request){ post :add_mentee, id: teacher.id  }
    before{ student }

    it "raises an exception if the user cannot add a mentee to a teacher" do
      ability.cannot :add_mentee, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a student_id" do
      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid student_id" do
      let(:make_request){ post :add_mentee, id: teacher.id, student_id: 4 }

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid student_id" do
      let(:make_request){ post :add_mentee, id: teacher.id, student_id: 5 }

      context "when the teacher contains that student" do
        before{ teacher.mentees = [student] }

        it "redirects to the teacher page" do
          make_request
          response.should redirect_to teacher_path(teacher)
        end

        it "sets a flash alert" do
          make_request
          flash[:alert].should be_present
        end
      end

      context "when the teacher does not contain that student" do
        it "redirects to the teacher page" do
          make_request
          response.should redirect_to teacher_path(teacher)
        end

        it "adds the student to the teacher" do
          make_request
          teacher.reload.mentees.should == [student]
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end


  describe "POST remove_mentee" do
    let(:teacher){ create(:teacher) }
    let(:student){ create(:student, id: 5) }
    let(:make_request){ post :remove_mentee, id: teacher.id  }
    before{ student }

    it "raises an exception if the user cannot remove a student to a teacher" do
      ability.cannot :remove_mentee, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a student_id" do
      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with an invalid student_id" do
      let(:make_request){ post :remove_mentee, id: teacher.id, student_id: 4 }

      it "redirects to the teacher page" do
        make_request
        response.should redirect_to teacher_path(teacher)
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end
    end

    context "with a valid student_id" do
      let(:make_request){ post :remove_mentee, id: teacher.id, student_id: 5 }

      context "when the teacher contains that student" do
        before{ teacher.mentees = [student] }

        it "redirects to the teacher page" do
          make_request
          response.should redirect_to teacher_path(teacher)
        end

        it "removes the student from the teacher" do
          make_request
          teacher.reload.mentees.should be_empty
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end

      context "when the teacher does not contain that student" do
        it "redirects to the teacher page" do
          make_request
          response.should redirect_to teacher_path(teacher)
        end

        it "sets a flash notice" do
          make_request
          flash[:notice].should be_present
        end
      end
    end
  end
end