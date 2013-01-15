class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, :office_phone, :address, :bloodgroup, :formatted_birthday

  before_destroy :clear_guardians

  has_and_belongs_to_many :guardians, uniq: true, join_table: :students_guardians
  has_and_belongs_to_many :groups, uniq: true, join_table: :students_groups
  has_and_belongs_to_many :mentors, class_name: Teacher, uniq: true, join_table: :student_mentors
  has_and_belongs_to_many :tagged_posts, class_name: Post, uniq: true
  has_many :student_observations, dependent: :destroy

  validates :bloodgroup, length: { maximum: 15 }

  scope :current, where(archived: false)
  scope :archived, where(archived: true)

  def name_with_type
    "#{full_name} (student)"
  end

  def self.filter_group(group_id)
    students = self.scoped
    students = students.has_group(group_id) if group_id.to_i > 0
    return students
  end
  
  def toggle_archive
    self.archived = !archived

    if archived
      user.deactivate if user.present?
      mentors.clear
    end

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

  def remaining_groups
    Group.where{ id.not_in( my{ group_ids } ) }
  end

  def remaining_teachers
    Teacher.current.where{ id.not_in( my{ mentor_ids } ) }
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

  private

  def self.has_group(group_id)
    where{ id.in( Student.select{id}.joins{ groups }.where{ groups.id == group_id } ) }
  end
end