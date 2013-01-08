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

  def name
    if first_name.present?
      first_name
    else
      last_name
    end
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

  module ClassMethods
    def alphabetical
      order(:first_name, :last_name)
    end

    def inputs
      self.fields.map { |field| field[:input] || field[:function] }
    end
  end

  def self.included(base)
    base.extend ClassMethods
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