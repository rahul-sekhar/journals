class TeacherProfile < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :password
  attr_accessor :password

  after_create :create_user

  has_one :user, as: :profile

  validates :last_name, presence: true
  validates :password, presence: true, if: :new_record?

  def create_user
    self.create_user!(username: get_username, password: @password)
  end

  def full_name
    if first_name.present?
      "#{first_name} #{last_name}"
    else
      last_name
    end
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