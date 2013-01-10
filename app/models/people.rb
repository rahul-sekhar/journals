class People < ActiveRecord::Base
  self.table_name = :people

  belongs_to :profile, polymorphic: true

  scope :alphabetical, order(:full_name)
  scope :current, where(archived: false)
  scope :archived, where(archived: true)
end