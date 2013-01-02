class User < ActiveRecord::Base
  attr_accessible :username, :password
  attr_accessor :password

  before_save :encrypt_password

  belongs_to :profile, polymorphic: true, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :username, presence: true, format: { with: /\A\w*\z/ }, uniqueness: true
  validates :password, presence: true, format: { with: /\A[^ ]*\z/ }, length: { minimum: 4 }
  validates :profile, presence: true

  def self.authenticate(username, password)
    user = find_by_username(username)
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
    profile.name
  end
end