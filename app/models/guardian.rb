class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :name, :email, :mobile, :home_phone, :office_phone, :address,
    :additional_emails, :notes

  has_and_belongs_to_many :students, uniq: true, join_table: :students_guardians

  def archived
    if students.all? { |student| student.archived }
      return true
    else
      return false
    end
  end

  def number_of_students
    students.length
  end

  def name_with_info
    if students.length == 1
      student_names = students.first.name

    elsif students.length > 1
      student_names = students_as_sentence
    end

    return "#{name} (guardian of #{student_names})"
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
    students.map{ |student| student.short_name }.sort.to_sentence
  end
end