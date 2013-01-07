class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, :office_phone, :address, :bloodgroup, :formatted_birthday

  before_destroy :clear_guardians

  has_and_belongs_to_many :guardians, uniq: true, join_table: :students_guardians
  has_many :student_observations, dependent: :destroy

  default_scope includes(:user)

  def name_with_type
    "#{full_name} (student)"
  end

  def toggle_archive
    self.archived = !archived
    user.deactivate if archived
    save
    guardians.each { |guardian| guardian.check_students }
  end

  def clear_guardians
    guardians_copy = guardians.all
    guardians.clear
    guardians_copy.each { |guardian| guardian.check_students }
  end

  def formatted_birthday
    birthday.strftime( '%d-%m-%Y' ) if birthday.present?
  end

  def formatted_birthday=(val)
    begin
      self.birthday = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.birthday = nil
    end
  end

  def age
    if birthday.present?
      now = Date.today
      dob = birthday
      return (now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1))
    end
  end

  def birthday_with_age
    "#{formatted_birthday} (#{age} yrs)" if birthday.present?
  end

  def self.fields
    [
      { name: "Birthday", function: :birthday_with_age, input: :formatted_birthday },
      { name: "Blood group", function: :bloodgroup },
      { name: "Mobile", function: :mobile },
      { name: "Home Phone", function: :home_phone },
      { name: "Office Phone", function: :office_phone },
      { name: "Email", function: :email },
      { name: "Address", function: :address, format: true },
    ]
  end
end