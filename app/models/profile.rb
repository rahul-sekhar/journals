module Profile
  def email=(val)
    build_user unless user.present?
    self.user.email = val
  end

  def email
    user.email if user.present?
  end

  def name
    first_name
  end

  def full_name
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      last_name
    end
  end

  def active?
    user.active?
  end

  def reset_password
    password = user.generate_password
    save
    return password
  end

  module ClassMethods
    def find_by_name(first_name, last_name)
      self.where(first_name: first_name, last_name: last_name).first
    end

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
    base.validates :last_name, presence: true
    base.validates :user, presence: true
    base.strip_attributes
  end

  private

  def duplicate_name?
    [Teacher, Student, Guardian].each do |klass|
      duplicates = klass.where(first_name: first_name)
      duplicates = duplicates.where{id != my{ id }} if klass == self.class
      return true if duplicates.count > 0
    end

    return false
  end
end