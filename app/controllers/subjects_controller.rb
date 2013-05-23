class SubjectsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:add_strand, :people]

  def index
    @subjects = @subjects.alphabetical
  end

  def show
    @student = Student.find(params[:student_id]) if params[:student_id]
  end

  def people
    authorize! :read, @subject
  end

  def create
    if @subject.save
      render "show_short"
    else
      render text: @subject.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @subject.update_attributes(params[:subject])
      render "show_short"
    else
      render text: @subject.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @subject.destroy
    render text: "OK", status: :ok
  end

  def add_strand
    authorize! :create, Strand

    @strand = @subject.add_strand(params[:strand][:name])
    if @strand.new_record?
      render text: @strand.errors.full_messages.first, status: :unprocessable_entity
    else
      render "strands/show"
    end
  end
end