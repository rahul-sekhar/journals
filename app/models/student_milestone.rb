class StudentMilestone < ActiveRecord::Base
  self.table_name = :students_milestones

  attr_accessible :status, :comments, :milestone_id

  after_save :check_if_empty

  belongs_to :milestone
  belongs_to :student
  has_one :subject, through: :milestone

  validates :milestone, presence: true
  validates :student, presence: true

  validates :milestone_id, uniqueness: { scope: :student_id }

  validates :status, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 3
  }

  def self.from_subject(subject)
    joins{milestone.strand}.where{milestone.strand.subject_id == subject.id}
  end

  def check_if_empty
    if (status == 0 && comments.blank?)
      destroy
    end
  end
end