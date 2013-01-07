class Teacher < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, :office_phone, :address

  default_scope includes(:user)

  def name_with_type
    "#{full_name} (teacher)"
  end

  def self.fields
    [
      { name: "Mobile", function: :mobile },
      { name: "Home Phone", function: :home_phone },
      { name: "Office Phone", function: :office_phone },
      { name: "Email", function: :email },
      { name: "Address", function: :address, format: true },
    ]
  end
end