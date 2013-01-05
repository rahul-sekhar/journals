class Guardian < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  belongs_to :student

  validates :student, presence: true

  def name_with_type
    "#{full_name} (guardian of #{student.full_name})"
  end
end