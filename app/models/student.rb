class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  has_many :guardians, dependent: :destroy
  has_many :student_observations, dependent: :destroy

  def name_with_type
    "#{full_name} (student)"
  end
end