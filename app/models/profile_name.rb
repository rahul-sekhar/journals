# Model for a view that returns the first name and initial of all profiles
class ProfileName < ActiveRecord::Base
  belongs_to :profile, polymorphic: true

  def self.excluding_profile(profile)
    where{ (profile_type != profile.class.to_s) | (profile_id != profile.id) }
  end
end