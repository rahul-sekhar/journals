module Profile
  def email=(val)
    if val.present?
      build_user unless user

      # Undo marked for destruction if it has been set
      if user.marked_for_destruction?
        if user.new_record?
          build_user
        else
          user.reload
        end
      end

      self.user.email = val
    else
      self.user.mark_for_destruction if user
    end
  end

  def email
    user.email if user.present?
  end

  def name=(val)
    words = val.split(" ")
    self.first_name = words.shift
    self.last_name = words.pop

    while words.length > 0 && ('a'..'z').member?(words.last[0])
      self.last_name = "#{words.pop} #{last_name}"
    end

    if words.length > 0
      self.first_name = "#{first_name} #{words.join(" ")}"
    end
  end

  def name
    if last_name.present?
      "#{first_name} #{last_name}"
    else
      first_name
    end
  end

  def active?
    user && user.active?
  end

  def reset_password
    return false if !user

    password = user.generate_password
    save
    return password
  end

  def check_profile_name
    # Check to see if the name has changed
    if (short_name != first_name && short_name != name && short_name != name)
      check_all_short_names
    end
  end

  def check_all_short_names
    [Student, Teacher, Guardian].each do |klass|
      klass.all.each do |profile|
        profile.set_short_name
      end
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

  module ClassMethods
    def search(query)
      query = "%#{SqlHelper::escapeWildcards(query)}%"
      where{ array_to_string(`ARRAY[first_name, last_name]`, ' ').like query }
    end

    def alphabetical
      order(:first_name, :last_name)
    end

    def name_is(first, last)
      names_are(first, last).first
    end

    def names_are(first, last)
      last = SqlHelper::escapeWildcards(last)
      first = SqlHelper::escapeWildcards(first)

      if first.blank?
        where{ ( first_name.like last ) & ( last_name == nil ) }
      elsif last.blank?
        where{ ( first_name.like first ) & ( last_name == nil ) }
      else
        where{( first_name.like first ) & ( last_name.like last )}
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods

    base.has_one :user, as: :profile, dependent: :destroy, autosave: true, inverse_of: :profile
    base.has_many :posts, as: :author, dependent: :destroy, inverse_of: :author
    base.has_many :comments, as: :author, dependent: :destroy, inverse_of: :author

    base.after_save :reload
    base.after_save :check_profile_name
    base.after_destroy :check_all_short_names

    base.validates :last_name, length: { maximum: 80 }
    base.validates :first_name, presence: true, length: { maximum: 80 }
    base.validates :mobile, length: { maximum: 40 }
    base.validates :home_phone, length: { maximum: 40 }
    base.validates :office_phone, length: { maximum: 40 }
    base.validates :additional_emails, length: { maximum: 100 }
    base.validates_associated :user

    base.strip_attributes
  end
end