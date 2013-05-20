class Subject < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  has_many :strands, dependent: :destroy

  strip_attributes

  scope :alphabetical, order(:name)

  def add_strand(strand_name)
    strands.create(name: strand_name)
  end

  def root_strands
    strands.where{ parent_strand_id == nil }
  end
end