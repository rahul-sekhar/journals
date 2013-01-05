module Profile
  attr_accessor :password, :email

  def build_user_if_new_record
    self.build_user(email: @email, password: @password) if new_record?
  end

  def full_name
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      last_name
    end
  end

  module ClassMethods
    def find_by_name(first_name, last_name)
      self.where(first_name: first_name, last_name: last_name).first
    end

    def alphabetical
      order(:first_name, :last_name)
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.before_validation :build_user_if_new_record
    base.has_one :user, as: :profile, dependent: :destroy, validate: true
    base.validates :last_name, presence: true
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