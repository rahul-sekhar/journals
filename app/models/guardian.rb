class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, :office_phone, :address

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

  def self.fields
    [
      { name: "Mobile", function: :mobile },
      { name: "Home Phone", function: :home_phone },
      { name: "Office Phone", function: :office_phone },
      { name: "Email", function: :email },
      { name: "Address", function: :address, format: true },
    ]
  end
end