class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :full_name, :email, :mobile, :home_phone, :office_phone, :address,
    :additional_emails, :notes

  has_and_belongs_to_many :students, uniq: true, join_table: :students_guardians

  default_scope includes(:user)

  def archived
    if students.all? { |student| student.archived }
      return true
    else
      return false
    end
  end

  def name_with_type
    if students.length == 1
      student_names = students.first.full_name

    elsif students.length > 1
      # Get an alphabetically sorted list of names
      student_names = students.alphabetical.map{ |student| student.name }

      # Join the array as a sentence
      student_names = student_names.to_sentence
    end
    
    return "#{full_name} (guardian of #{student_names})"
  end

  def check_students
    # Check if all students are archived
    if students.all? { |student| student.archived }
      user.deactivate if user
      save
    end

    destroy if students.reload.empty?
  end

  def students_as_sentence
    students.alphabetical.map{ |student| student.name }.to_sentence
  end
end