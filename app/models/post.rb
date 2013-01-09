class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_names, :teacher_ids, :student_ids, :visible_to_guardians, :visible_to_students, :student_observations_attributes

  before_save :check_permissions
  before_validation :check_student_observations, :check_self_tag

  belongs_to :author, polymorphic: true
  has_and_belongs_to_many :tags, uniq: true, validate: true
  has_and_belongs_to_many :teachers, uniq: true
  has_and_belongs_to_many :students, uniq: true
  has_many :comments, dependent: :destroy, order: :created_at
  has_many :student_observations, inverse_of: :post, dependent: :destroy

  accepts_nested_attributes_for :student_observations

  validates :title, 
    presence: { message: "Please enter a post title" },
    length: { maximum: 255, message: "The title cannot be longer than 255 letters" }
  validates :author, presence: true

  strip_attributes

  # Posts that are either authored by the guardian or that have one of the guardian's students tagged and have guardian permissions allowed
  def self.readable_by_guardian(guardian)
    student_ids = guardian.students.map{ |student| student.id }
    
    where{
      ( 
        ( author_id == guardian.id ) & ( author_type == "Guardian" ) 
      ) |
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
    return if author.blank?

    # Automatically set the tag if the author is a student
    if author.is_a? Student
      self.students << author unless students.exists?(author)
    end

    # If the author is a guardian and none of their students are tagged, invalidate the post
    if ( author.is_a? Guardian ) && ( author.students & students ).empty?
      errors.add(:students, "You must tag at least one of your own students")
    end

    return nil
  end

  def check_permissions
    self.visible_to_students = true if author.is_a? Student
    self.visible_to_guardians = true if ( author.is_a? Student ) || ( author.is_a? Guardian )
    return nil
  end

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end

  def initialize_tags
    if author.is_a? Teacher
      self.teachers = [author]
      self.students.clear
    elsif author.is_a? Student
      self.students = [author]
      self.teachers.clear
    elsif author.is_a? Guardian
      self.students = author.students
      self.teachers.clear
    end
  end

  def initialize_observations
    if author.is_a? Teacher
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
    tags = Tag.find_or_build_list(tag_names)

    # Add existing tags
    self.tags = tags.reject{ |tag| tag.new_record? }

    # Build new tags
    tags.select{ |tag| tag.new_record? }.each do |tag|
      self.tags.build(name: tag.name)
    end
  end
end