class User < ActiveRecord::Base
  attr_accessible :email, :password
  attr_accessor :password

  before_save :encrypt_password

  belongs_to :profile, polymorphic: true, inverse_of: :user
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email,
    presence: true,
    format: { with: /.+@.+\..+/ },
    uniqueness: { case_sensitive: false }
  validates :password,
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

  def generate_password
    self.password = (0...10).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def active?
    password_salt.present? && password_hash.present?
  end

  def name
    profile.name
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