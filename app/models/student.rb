class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  before_destroy :check_guardians
  
  has_and_belongs_to_many :guardians, uniq: true, join_table: :students_guardians
  has_many :student_observations, dependent: :destroy

  def name_with_type
    "#{full_name} (student)"
  end

  def check_guardians
    guardians_copy = guardians.all
    guardians.clear
    guardians_copy.each { |guardian| guardian.check_students }
  end
end