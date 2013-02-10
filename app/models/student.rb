class Student < ActiveRecord::Base
  include Profile

  attr_accessible :first_name, :last_name, :email, :mobile, :home_phone, 
    :office_phone, :address, :blood_group, :formatted_birthday,
    :additional_emails, :notes

  before_destroy :clear_guardians

  has_and_belongs_to_many :guardians, uniq: true, join_table: :students_guardians
  has_and_belongs_to_many :groups, uniq: true, join_table: :students_groups
  has_and_belongs_to_many :mentors, class_name: Teacher, uniq: true, join_table: :student_mentors
  has_and_belongs_to_many :tagged_posts, class_name: Post, uniq: true
  has_many :student_observations, dependent: :destroy

  validates :blood_group, length: { maximum: 15 }
  validates :birthday, presence: { message: "is invalid" }, if: "formatted_birthday.present?"

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

  def formatted_birthday
    if @formatted_birthday.present?
      @formatted_birthday
    elsif birthday.present?
      birthday.strftime( '%d-%m-%Y' )
    end
  end

  def formatted_birthday=(val)
    @formatted_birthday = val
    begin
      self.birthday = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.birthday = nil
    end
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

  def remaining_groups
    Group.where{ id.not_in( my{ group_ids } ) }
  end

  def remaining_teachers
    Teacher.current.where{ id.not_in( my{ mentor_ids } ) }
  end  

  private

  def self.has_group(group_id)
    where{ id.in( Student.select{id}.joins{ groups }.where{ groups.id == group_id } ) }
  end
end