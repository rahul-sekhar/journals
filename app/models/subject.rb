class Subject < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  strip_attributes

  scope :alphabetical, order(:name)
end