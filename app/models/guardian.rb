class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  belongs_to :student

  validates :student, presence: true
end