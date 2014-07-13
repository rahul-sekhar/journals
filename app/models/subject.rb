class Subject < ActiveRecord::Base
  attr_accessible :name, :column_name, :level_numbers

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  has_many :strands, dependent: :destroy, include: [:child_strands, :milestones]
  has_many :subject_teachers, dependent: :destroy
  has_many :teachers, through: :subject_teachers
  has_many :units, dependent: :destroy

  strip_attributes

  scope :alphabetical, order(:name)

  def add_strand(strand_name)
    strands.create(name: strand_name)
  end

  def root_strands
    strands.where{ parent_strand_id == nil }
  end

  def add_teacher(teacher)
    return self.subject_teachers.create(teacher: teacher)
  end
end