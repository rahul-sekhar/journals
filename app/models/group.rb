class Group < ActiveRecord::Base
  include Taggable

  attr_accessible :name

  has_and_belongs_to_many :students, uniq: true, join_table: :students_groups

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 50 }

  strip_attributes
end