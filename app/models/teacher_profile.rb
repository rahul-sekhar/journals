class TeacherProfile < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :password
  attr_accessor :password

  after_create :create_user

  has_one :user, as: :profile, dependent: :destroy
 
  validates :last_name, presence: true
  validates :password, 
    presence: true, 
    format: { with: /\A[^ ]*\z/ }, 
    length: { minimum: 4 },
    if: :new_record?

  strip_attributes

  def create_user
    self.create_user!(username: get_username, password: @password)
  end

  def name
    # Check for other teacher profiles with the same name, excluding the current one
    if TeacherProfile.where{id != my{ id }}.where(first_name: first_name).count > 0
      return full_name
    else
      return first_name
    end
  end

  def full_name
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      last_name
    end
  end

  def self.find_by_name(first_name, last_name)
    self.where(first_name: first_name, last_name: last_name).first
  end

  private
  def get_username
    if first_name.present?
      username = prepare_username(first_name)
    else
      username = prepare_username(last_name)
    end

    if User.exists?(username: username)
      username = prepare_username(full_name)

      full_username = username
      i = 0
      while User.exists?(username: username) do
        i += 1
        username = "#{full_username}_#{i}"
      end
    end

    return username
  end

  def prepare_username(unprepared_username)
    unprepared_username.downcase.gsub(' ', '_').gsub(/\W/, '')
  end
end