class SubjectTeacher < ActiveRecord::Base
  attr_accessible :teacher

  belongs_to :subject
  belongs_to :teacher

  has_and_belongs_to_many :students, join_table: :subject_teacher_students

  validates :subject, presence: true
  validates :teacher, presence: true
  validates :teacher_id, uniqueness: { scope: :subject_id }
end