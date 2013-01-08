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

  def self.find_or_build_list(names)
    names.split(',')
      .map{ |name| name.strip }
      .reject{ |name| name.blank? }
      .uniq{ |tag| tag.downcase }
      .map { |name| name_is(name) || new(name: name) }
  end
end