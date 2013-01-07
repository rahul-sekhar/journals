class Teacher < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :password

  default_scope includes(:user)

  def name_with_type
    "#{full_name} (teacher)"
  end
end