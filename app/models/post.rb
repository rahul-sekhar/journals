class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_names, :teacher_ids, :student_ids, :visible_to_guardians, :visible_to_students, :student_observations_attributes

  before_save :check_permissions
  before_validation :check_student_observations, :check_self_tag

  belongs_to :user
  has_and_belongs_to_many :tags, uniq: true, validate: true
  has_and_belongs_to_many :teachers, uniq: true
  has_and_belongs_to_many :students, uniq: true
  has_many :comments, dependent: :destroy
  has_many :student_observations, inverse_of: :post, dependent: :destroy

  accepts_nested_attributes_for :student_observations

  validates :title, presence: { message: "Please enter a post title" }
  validates :user, presence: true

  # Posts that are either authored by the guardian or that have one of the guardian's students tagged and have guardian permissions allowed
  def self.readable_by_guardian(guardian)
    student_ids = guardian.students.map{ |student| student.id }
    
    where{
      ( user_id == guardian.user.id ) |
      ( 
        ( visible_to_guardians == true ) &
        ( id.in ( Post.select{id}.joins{ students }.where{ students.id.in( student_ids )}) )
      )
    }
  end

  def check_student_observations
    student_observations.each do |obs|
      if obs.content.blank? || !students.include?(obs.student)
        obs.mark_for_destruction
      end
    end
  end

  def check_self_tag
    return if user.blank?

    # Automatically set the tag if the author is a student
    if user.is_student?
      self.students << author_profile unless students.exists?(author_profile)
    end

    # If the author is a guardian and none of their students are tagged, invalidate the post
    if user.is_guardian? && (user.profile.students & students).empty?
      errors.add(:students, "You must tag at least one of your own students")
    end

    return nil
  end

  def check_permissions
    self.visible_to_students = true if user.is_student?
    self.visible_to_guardians = true if user.is_student? || user.is_guardian?
    return nil
  end

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end

  def author_profile
    user.profile
  end

  def initialize_tags
    if user.is_teacher?
      self.teachers = [author_profile]
      self.students.clear
    elsif user.is_student?
      self.students = [author_profile]
      self.teachers.clear
    elsif user.is_guardian?
      self.students = author_profile.students
      self.teachers.clear
    end
  end

  def initialize_observations
    if user.is_teacher?
      students.each do |student|
        if student_observations.where(student_id: student.id).empty?
          self.student_observations.build(student_id: student.id)
        end
      end
    end
  end

  def tag_names
    tags.map{ |tag| tag.name }.sort.join(", ")
  end

  def tag_names=(tag_names)
    self.tags.clear

    # Split a comma separated list of tag names into an array of trimmed names
    tag_name_array = tag_names.split(",").map{ |name| name.strip }

    # Remove duplicates case insensitively and blank items
    tag_name_array = tag_name_array.reject{ |tag| tag.blank? }.uniq{ |tag| tag.downcase }

    tag_name_array.each do |tag_name|
      existing_tag = Tag.name_is(tag_name)
      if existing_tag
        self.tags << existing_tag
      else
        self.tags.build(name: tag_name)
      end
    end
  end
end