class User < ActiveRecord::Base
  attr_accessible :email, :current_password, :new_password
  attr_accessor :new_password, :current_password, :generated_password

  before_save :encrypt_password
  before_validation :check_current_password

  belongs_to :profile, polymorphic: true, inverse_of: :user

  validates :email,
    presence: true,
    format: { with: /\A[\w.-]+@[\w-]+\.[\w.]+\z/ },
    length: { maximum: 60 },
    uniqueness: { case_sensitive: false }
  validates :new_password,
    format: { with: /\A[^ ]*\z/ },
    length: { minimum: 4 },
    confirmation: true,
    allow_blank: true

  def self.authenticate(email, password)
    user = User.where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      return user
    else
      return nil
    end
  end

  def check_current_password
    if new_password.present?
      unless User.authenticate(email, current_password) == self
        errors.add(:current_password, "is incorrect")
      end
    end
  end


  # Only intended for testing and administrative use
  def set_password(password)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    self.new_password = nil
    self.generated_password = nil
    save
  end

  def generate_password
    self.generated_password = (0...10).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def encrypt_password
    if new_password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(new_password, password_salt)
    elsif generated_password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(generated_password, password_salt)
    elsif password_salt.blank?
      self.password_salt = BCrypt::Engine.generate_salt
    end
  end

  def active?
    password_hash.present?
  end

  def deactivate
    self.password_hash = nil
    self.new_password = nil
    self.generated_password = nil
    save
  end

  def is_teacher?
    profile_type == "Teacher"
  end

  def is_student?
    profile_type == "Student"
  end

  def is_guardian?
    profile_type == "Guardian"
  end
end