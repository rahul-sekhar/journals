class Strand < ActiveRecord::Base
  attr_accessible :name

  default_scope order(:position)

  before_create :set_position
  after_destroy :set_subsequent_sibling_positions

  belongs_to :subject
  belongs_to :parent_strand, class_name: Strand
  has_many :child_strands, foreign_key: :parent_strand_id, class_name: Strand, dependent: :destroy
  has_many :milestones, dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 80 }

  validates :subject, presence: true

  strip_attributes

  def add_strand(strand_name)
    raise 'Strand cannot have both milestones and child strands' if milestones.length > 0

    child = child_strands.build(name: strand_name)
    child.subject = subject
    child.save
    return child
  end

  def add_milestone(level, content)
    raise 'Strand cannot have both milestones and child strands' if child_strands.length > 0

    return milestones.create(level: level, content: content)
  end

  private

  def siblings
    Strand.where{
      (subject_id == my{subject_id}) &
      (parent_strand_id == my{parent_strand_id}) &
      (id != my{id})
    }
  end

  def set_position
    self.position = siblings.maximum(:position).to_i + 1
  end

  def set_subsequent_sibling_positions
    siblings.where{position > my{position}}.each do |strand|
      strand.position -= 1
      strand.save!
    end
  end
end