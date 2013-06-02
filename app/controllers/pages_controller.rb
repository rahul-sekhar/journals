class PagesController < ApplicationController
  skip_authorization_check

  def home
    redirect_to posts_path
  end

  def user
    @profile = current_profile
  end

  def people
    if params[:filter] == 'students'
      @people = Student.current

    elsif params[:filter] == 'teachers'
      @people = Teacher.current

    elsif params[:filter] == 'mentees'
      if current_profile.is_a? Teacher
        @people = current_profile.mentees
      else
        @people = Student.where("1 = 0")
      end

    elsif params[:filter] == 'archived'
      map_profiles = true
      @people = People.archived

    elsif params[:filter].to_s[0..5] == 'group-'
      group = Group.find_by_id(params[:filter][6..-1])
      if (group)
        @people = group.students.current
      else
        @people = Student.where("1 = 0")
      end

    else
      map_profiles = true
      @people = People.current
    end

    @people = @people.alphabetical.load_associations
    @people = @people.search(params[:search]) if params[:search]

    @people = paginate(@people)
    @people = @people.map{ |person| person.profile } if map_profiles

    render "pages/people"
  end

  def update_password
    if params['user']
      @current_pass = params['user']['current_password']
      @new_pass = params['user']['new_password']
    end

    if @current_pass.present? && @new_pass.present?
      current_user.current_password = @current_pass
      current_user.new_password = @new_pass

      if current_user.save
        render text: 'OK', status: :ok
      else
        render text: current_user.errors.full_messages.first, status: :unprocessable_entity
      end

    elsif @current_pass.blank?
      render text: "Please enter your current password", status: :unprocessable_entity

    elsif @new_pass.blank?
      render text: "Please enter a new password", status: :unprocessable_entity

    end
  end

  def academics
    if (current_profile.is_a? Teacher)
      @summarized_academics = SummarizedAcademic.for_teacher(current_profile)
    elsif (current_profile.is_a? Student)
      @summarized_academics = SummarizedAcademic.for_students([current_profile.id])
    elsif (current_profile.is_a? Guardian)
      @summarized_academics = SummarizedAcademic.for_students(current_profile.student_ids)
    end

    @summarized_academics = @summarized_academics.order(:student_id)
  end
end