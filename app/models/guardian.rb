class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  has_and_belongs_to_many :students, uniq: true, join_table: :students_guardians

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
    destroy if students.reload.empty?
  end
end