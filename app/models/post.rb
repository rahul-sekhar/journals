class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_names, :teacher_ids, :student_ids

  belongs_to :user
  has_and_belongs_to_many :tags, uniq: true, validate: true
  has_and_belongs_to_many :teachers, uniq: true
  has_and_belongs_to_many :students, uniq: true

  validates :title, presence: true
  validates :user, presence: true

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end

  def author_name
    user.name
  end

  def author_profile
    user.profile
  end

  def initialize_tag
    if user.is_teacher?
      self.teachers = [author_profile]
      self.students.clear
    else
      self.students = [author_profile]
      self.teachers.clear
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