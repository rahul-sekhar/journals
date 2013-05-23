class Student < ActiveRecord::Base
  include Profile

  attr_accessible :name, :email, :mobile, :home_phone,
    :office_phone, :address, :blood_group, :birthday,
    :additional_emails, :notes

  before_destroy :clear_guardians

  has_and_belongs_to_many :guardians, uniq: true, join_table: :students_guardians
  has_and_belongs_to_many :groups, uniq: true, join_table: :students_groups
  has_and_belongs_to_many :mentors, class_name: Teacher, uniq: true, join_table: :student_mentors
  has_and_belongs_to_many :tagged_posts, class_name: Post, uniq: true
  has_many :student_observations, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :student_milestones, dependent: :destroy

  has_many :mentees, class_name: NullAssociation, foreign_key: :foreign_id

  validates :blood_group, length: { maximum: 15 }
  validates :birthday_raw, presence: { message: "is invalid" }, if: "birthday.present?"

  scope :load_associations, includes(:user, { guardians: [:user, :students ]}, :groups, :mentors)
  scope :current, where(archived: false)
  scope :archived, where(archived: true)

  def name_with_info
    "#{name} (student)"
  end

  def self.filter_group(group_id)
    students = self.scoped
    students = students.has_group(group_id) if group_id.to_i > 0
    return students
  end

  def birthday
    if @birthday.present?
      @birthday
    elsif birthday_raw.present?
      birthday_raw.strftime( '%d-%m-%Y' )
    end
  end

  def birthday=(val)
    @birthday = val
    begin
      self.birthday_raw = Date.strptime( val, '%d-%m-%Y' )
    rescue
      self.birthday_raw = nil
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

  private

  def self.has_group(group_id)
    where{ id.in( Student.select{id}.joins{ groups }.where{ groups.id == group_id } ) }
  end
end