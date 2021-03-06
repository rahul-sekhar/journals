class People < ActiveRecord::Base
  self.table_name = :people

  belongs_to :profile, polymorphic: true

  scope :alphabetical, order(:full_name)
  scope :current, where(archived: false)
  scope :archived, where(archived: true)

  scope :load_associations, includes(profile: [:user, :groups, :mentors, :mentees, { guardians: [:user, :students] }])

  def self.search( query )
    query = "%#{SqlHelper::escapeWildcards(query)}%"
    where{ full_name.like query }
  end
end