require 'spec_helper'

describe TeachersController, :focus do
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
      expect{ get :index, format: :json }.to raise_exception(CanCan::AccessDenied)
    end

    it "has a status of 200" do
      get :index, format: :json
      response.status.should == 200
    end

    it "assigns any teachers into a profiles collection" do
      student1 = create(:student)
      teacher1 = create(:teacher)
      teacher2 = create(:teacher)
      get :index, format: :json
      assigns(:people).should =~ [teacher1, teacher2]
    end

    it "does not assign archived teachers" do
      teacher1 = create(:teacher)
      teacher2 = create(:teacher, archived: true)
      get :index, format: :json
      assigns(:people).should == [teacher1]
    end

    it "sorts the teachers alphabetically" do
      teacher1 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      teacher2 = create(:teacher, first_name: "Ze", last_name: "Teacher")
      teacher3 = create(:teacher, first_name: "A", last_name: "Teacher")
      get :index, format: :json
      assigns(:people).should == [teacher3, teacher1, teacher2]
    end

    it "searches for teachers when the search parameter is passed" do
      teacher1 = create(:teacher, first_name: "Rahul", last_name: "Sekhar")
      teacher2 = create(:teacher, first_name: "Ze", last_name: "Teacher")
      teacher3 = create(:teacher, first_name: "A", last_name: "Teacher")
      get :index, search: "ra", format: :json
      assigns(:people).should == [teacher1]
    end

    describe "pagination" do
      def create_items(num)
        create_list(:teacher, num)
      end

      def make_request(page=nil)
        if page
          get :index, page: page, format: :json
        else
          get :index, format: :json
        end
      end

      let(:item_list_name){ :people }

      it_behaves_like "a paginated page"
    end
  end


  describe "GET show" do
    let(:teacher){ mock_model(Teacher) }
    before { Teacher.stub(:find).and_return(teacher) }

    it "raises an exception if the user cannot view the teacher" do
      ability.cannot :read, teacher
      expect{ get :show, id: 5, format: :json }.to raise_exception(CanCan::AccessDenied)
    end
    
    it "has a status of 200" do
      get :show, id: 5, format: :json
      response.status.should eq(200)
    end

    it "finds the teacher given by the passed ID" do
      Teacher.should_receive(:find).with("5")
      get :show, id: 5, format: :json
    end

    it "assigns the found teacher" do
      get :show, id: 5, format: :json
      assigns(:teacher).should == teacher
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

      it "stores already filled data in a flash object" do
        make_request
        flash[:teacher_data].should == { 'first_name' => ' ' }
      end
    end
  end


  describe "PUT update" do
    let(:teacher){ create(:teacher) }

    context "with valid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { full_name: "Rahul Sekhar", email: "rahul@mail.com" }, format: :json }

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

      it "renders the show page" do
        make_request
        response.should render_template "show"
      end
    end

    context "with invalid data" do
      let(:make_request){ put :update, id: teacher.id, teacher: { full_name: "", email: "rahul@mail.com" }, format: :json }

      it "does not edit the teacher" do
        make_request
        teacher.reload.email.should_not == "rahul@mail.com"
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
    let(:teacher){ create(:teacher) }
    let(:make_request){ delete :destroy, id: teacher.id, format: :json }

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

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end
  end


  describe "POST reset" do
    let(:make_request){ post :reset, id: teacher.id, format: :json }

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
        teacher.reset_password
        mock_delay = double('mock_delay')
        UserMailer.stub(:delay).and_return(mock_delay)
        mock_delay.should_receive(:reset_password_mail)
        make_request
      end
    end

    context "when email is not present" do
      let(:teacher){ create(:teacher) }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end

      it "does not deliver a mail" do
        UserMailer.should_not_receive(:delay)
        make_request
      end

      it "does not activate the guardian" do
        make_request
        teacher.reload.should_not be_active
      end
    end
  end


  describe "POST archive" do
    let(:teacher){ create(:teacher) }
    let(:make_request){ post :archive, id: teacher.id, format: :json }
    before{ teacher }

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

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end
  end


  describe "POST add_mentee" do
    let(:teacher){ create(:teacher) }
    let(:student){ create(:student, id: 5) }
    let(:make_request){ post :add_mentee, id: teacher.id, format: :json  }
    before{ student }

    it "raises an exception if the user cannot add a mentee to a teacher" do
      ability.cannot :add_mentee, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a student_id" do
      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with an invalid student_id" do
      let(:make_request){ post :add_mentee, id: teacher.id, student_id: 4, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with a valid student_id" do
      let(:make_request){ post :add_mentee, id: teacher.id, student_id: 5, format: :json }

      context "when the teacher contains that student" do
        before{ teacher.mentees = [student] }

        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end
      end

      context "when the teacher does not contain that student" do
        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end

        it "adds the student to the teacher" do
          make_request
          teacher.reload.mentees.should == [student]
        end
      end
    end
  end


  describe "POST remove_mentee" do
    let(:teacher){ create(:teacher) }
    let(:student){ create(:student, id: 5) }
    let(:make_request){ post :remove_mentee, id: teacher.id, format: :json }
    before{ student }

    it "raises an exception if the user cannot remove a student to a teacher" do
      ability.cannot :remove_mentee, teacher
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    context "without a student_id" do
      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with an invalid student_id" do
      let(:make_request){ post :remove_mentee, id: teacher.id, student_id: 4, format: :json }

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end

    context "with a valid student_id" do
      let(:make_request){ post :remove_mentee, id: teacher.id, student_id: 5, format: :json }

      context "when the teacher contains that student" do
        before{ teacher.mentees = [student] }

        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end

        it "removes the student from the teacher" do
          make_request
          teacher.reload.mentees.should be_empty
        end
      end

      context "when the teacher does not contain that student" do
        it "has a status of 200" do
          make_request
          response.status.should eq(200)
        end
      end
    end
  end
end