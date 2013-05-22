class SubjectTeachersController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :subject
  skip_load_resource only: :create

  def create
    @subject_teacher = @subject.add_teacher(Teacher.find(params[:subject_teacher][:teacher_id]))

    if @subject_teacher.new_record?
      render text: @subject_teacher.errors.full_messages.first, status: :unprocessable_entity
    else
      render partial: "subject_teacher", locals: { subject_teacher: @subject_teacher }
    end
  end

  def destroy
    @subject_teacher.destroy
    render text: "OK", status: :ok
  end

  def add_student
    @student = Student.find_by_id(params[:student_id])

    if @student
      @subject_teacher.students << @student unless @subject_teacher.students.exists? @student
      render text: "OK", status: :ok
    else
      render text: "Student does not exist", status: :unprocessable_entity
    end
  end

  def remove_student
    @student = Student.find_by_id(params[:student_id])

    if @student
      @subject_teacher.students.delete(@student) if @subject_teacher.students.exists? @student
      render text: 'OK', status: :ok
    else
      render text: "Student does not exist", status: :unprocessable_entity
    end
  end
end