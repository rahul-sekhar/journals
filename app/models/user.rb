class User < ActiveRecord::Base
  attr_accessible :email, :password
  attr_accessor :password

  before_save :encrypt_password

  belongs_to :profile, polymorphic: true, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, 
    presence: true, 
    format: { with: /.+@.+\..+/ }, 
    uniqueness: { case_sensitive: false }
  validates :password, 
    presence: true, 
    format: { with: /\A[^ ]*\z/ }, 
    length: { minimum: 4 }

  def self.authenticate(email, password)
    user = User.where(email: email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      return user
    else
      return nil
    end
  end

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def name
    profile.first_name
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