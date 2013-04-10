class ProfileName < ActiveRecord::Base
  belongs_to :profile, polymorphic: true

  def self.excluding_profile(profile)
    where{ (profile_type != profile.class.to_s) | (profile_id != profile.id) }
  end
end

module Profile
  def name
    if last_name.present?
      "#{first_name} #{last_name}"
    else
      first_name
    end
  end

  def set_short_name
    new_short_name = find_short_name

    if short_name != new_short_name
      self.short_name = new_short_name
      save!
    end
  end

  def find_short_name
    if last_name
      initial = last_name[0]

      # Check for duplicate first names
      other_profiles = ProfileName.excluding_profile(self)
      if ( other_profiles.where(first_name: first_name).exists? )

        # Check for duplicate initials
        if ( other_profiles.where(first_name: first_name, initial: initial).exists? )
          return name

        else
          return "#{first_name} #{initial}."
        end
      else
        return first_name
      end
    else
      return first_name
    end
  end
end

class Student < ActiveRecord::Base
  include Profile
end

class Teacher < ActiveRecord::Base
  include Profile
end

class Guardian < ActiveRecord::Base
  include Profile
end

class StoreProfileName < ActiveRecord::Migration
  def up
    add_column :students, :short_name, :string, limit: 161
    add_column :teachers, :short_name, :string, limit: 161
    add_column :guardians, :short_name, :string, limit: 161

    [Student, Teacher, Guardian].each do |klass|
      klass.all.each do |profile|
        profile.set_short_name
      end
    end
  end

  def down
    remove_column :students, :short_name
    remove_column :teachers, :short_name
    remove_column :guardians, :short_name
  end
end
