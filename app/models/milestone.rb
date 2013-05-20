class Milestone < ActiveRecord::Base
  attr_accessible :level, :content

  default_scope order(:position)

  before_create :set_position
  after_destroy :set_subsequent_sibling_positions

  belongs_to :strand

  validates :strand, presence: true
  validates :content, presence: true
  validates :level, presence: true

  strip_attributes

  private

  def siblings
    Milestone.where{
      (strand_id == my{strand_id}) &
      (level == my{level}) &
      (id != my{id})
    }
  end

  def set_position
    self.position = siblings.maximum(:position).to_i + 1
  end

  def set_subsequent_sibling_positions
    siblings.where{position > my{position}}.each do |milestone|
      milestone.position -= 1
      milestone.save!
    end
  end
end