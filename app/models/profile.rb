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

  def full_name
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      last_name
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

  def name
    if first_name

      initial = last_name[0]

      # Check for duplicate first names
      other_profiles = ProfileName.excluding_profile(self)
      if ( other_profiles.where(first_name: first_name).exists? )

        # Check for duplicate last_names
        if ( other_profiles.where(first_name: first_name, initial: initial).exists? )
          return full_name

        else
          return "#{first_name} #{initial}."
        end
      else
        return first_name
      end
    else
      return last_name
    end
  end

  def check_last_name
    if last_name.blank? && first_name.present?
      self.last_name = first_name
      self.first_name = nil
    end
  end

  module ClassMethods
    def search(query)
      query = "%#{SqlHelper::escapeWildcards(query)}%"
      where{ ((first_name.op('||', ' ')).op('||', 'last_name')).like query }
    end

    def alphabetical
      order(:first_name, :last_name)
    end

    def inputs
      self.fields.map { |field| field[:input] || field[:function] }
    end

    def name_is(first, last)
      names_are(first, last).first
    end

    def names_are(first, last)
      last = SqlHelper::escapeWildcards(last)
      first = SqlHelper::escapeWildcards(first)
      
      if first.blank?
        where{ last_name.like last }
      elsif last.blank?
        where{ last_name.like first }
      else
        where{( first_name.like first ) & ( last_name.like last )}
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.before_validation :check_last_name

    base.has_one :user, as: :profile, dependent: :destroy, autosave: true, inverse_of: :profile
    base.has_many :posts, as: :author, dependent: :destroy, inverse_of: :author
    base.has_many :comments, as: :author, dependent: :destroy, inverse_of: :author

    base.validates :last_name, presence: true, length: { maximum: 80 }
    base.validates :first_name, length: { maximum: 80 }
    base.validates :mobile, length: { maximum: 40 }
    base.validates :home_phone, length: { maximum: 40 }
    base.validates :office_phone, length: { maximum: 40 }
    
    base.strip_attributes
  end
end