class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  has_many :guardians, dependent: :destroy
end