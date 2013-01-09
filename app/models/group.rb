class Group < ActiveRecord::Base
  include Taggable

  attr_accessible :name

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  strip_attributes
end