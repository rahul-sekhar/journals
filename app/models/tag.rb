class Tag < ActiveRecord::Base
  attr_accessible :name

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  strip_attributes

  def self.name_is(tag_name)
    self.where{ name.like tag_name }.first
  end
end