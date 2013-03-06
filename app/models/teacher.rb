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
end