class Teacher < ActiveRecord::Base
  include Profile

  attr_accessible :full_name, :email, :mobile, :home_phone, :office_phone, :address,
    :additional_emails, :notes

  has_and_belongs_to_many :mentees, class_name: Student, uniq: true, join_table: :student_mentors
  has_and_belongs_to_many :ordered_mentees, class_name: Student, uniq: true, join_table: :student_mentors, order: "students.first_name, students.last_name"

  has_many :ordered_groups, class_name: NullAssociation, foreign_key: :foreign_id
  has_many :ordered_mentors, class_name: NullAssociation, foreign_key: :foreign_id
  has_many :ordered_guardians, class_name: NullAssociation, foreign_key: :foreign_id

  scope :load_associations, includes(:user, :ordered_mentees)
  scope :current, where(archived: false)
  scope :archived, where(archived: true)

  def name_with_info
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