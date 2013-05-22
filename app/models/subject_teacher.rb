class SubjectTeacher < ActiveRecord::Base
  attr_accessible :teacher

  belongs_to :subject
  belongs_to :teacher

  validates :subject, presence: true
  validates :teacher, presence: true
  validates :teacher_id, uniqueness: { scope: :subject_id }
end