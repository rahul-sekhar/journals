class Teacher < ActiveRecord::Base
  include Profile

  attr_accessible :full_name, :email, :mobile, :home_phone, :office_phone, :address,
    :additional_emails, :notes

  has_and_belongs_to_many :mentees, class_name: Student, uniq: true, join_table: :student_mentors

  default_scope includes(:user)
  scope :current, where(archived: false)
  scope :archived, where(archived: true)

  def name_with_type
    "#{full_name} (teacher)"
  end

  def toggle_archive
    self.archived = !archived

    if archived
      user.deactivate if user.present?
      mentees.clear
    end

    save
  end

  def remaining_students
    Student.current.where{ id.not_in( my{ mentee_ids } ) }
  end

  def self.fields
    [
      { name: "Mobile", function: :mobile },
      { name: "Home Phone", function: :home_phone },
      { name: "Office Phone", function: :office_phone },
      { name: "Email", function: :email },
      { name: "Additional Emails", function: :additional_emails },
      { name: "Address", function: :address, format: true },
      { name: "Notes", function: :notes, format: true }
    ]
  end
end