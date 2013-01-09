class Teacher < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, :office_phone, :address

  has_and_belongs_to_many :mentees, class_name: Student, uniq: true, join_table: :student_mentors

  def name_with_type
    "#{full_name} (teacher)"
  end

  def toggle_archive
    self.archived = !archived
    user.deactivate if (user && archived)
    save
  end

  def remaining_students
    Student.where{ id.not_in( my{ mentee_ids } ) }
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