class Post < ActiveRecord::Base
  attr_accessible :title, :content, :tag_names, :teacher_ids, :student_ids, :visible_to_guardians, :visible_to_students, :student_observations_attributes, :image_ids

  before_save :check_permissions
  before_validation :check_student_observations, :check_self_tag, :sanitize_content

  belongs_to :author, polymorphic: true
  has_and_belongs_to_many :tags, uniq: true, validate: true
  has_and_belongs_to_many :teachers, uniq: true
  has_and_belongs_to_many :students, uniq: true
  has_many :comments, dependent: :destroy, order: :created_at
  has_many :student_observations, inverse_of: :post, dependent: :destroy
  has_many :images, dependent: :destroy

  accepts_nested_attributes_for :student_observations

  validates :title,
    presence: true,
    length: { maximum: 255 }
  validates :author, presence: true

  strip_attributes

  scope :load_associations, includes(:students, :teachers, :tags, :comments, :student_observations)

  def self.author_is(profile)
    where { (post.author_id == profile.id) && (post.author_type == profile.class.to_s) }
  end

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

  def self.filter_by_params(params)
    posts = self.scoped
    posts = posts.search(params[:search]) if params[:search]
    posts = posts.has_group(params[:group]) if params[:group].to_i > 0
    posts = posts.has_student(params[:student]) if params[:student].to_i > 0
    posts = posts.has_tag(params[:tag]) if params[:tag].to_i > 0
    posts = posts.date_from(params[:dateFrom]) if params[:dateFrom]
    posts = posts.date_to(params[:dateTo]) if params[:dateTo]
    return posts
  end

  def sanitize_content
    self.content = Sanitize.clean( content,
      elements: %w[a span p img em strong br ul ol li],
      attributes: {
        :all => ['class'],
        'a' => ['href', 'title'],
        'img' => ['alt', 'src', 'title', 'height', 'width']
      },
      protocols: {
        'a'   => { 'href' => ['http', 'https', 'mailto', :relative] },
        'img' => {'src' => ['http', 'https', :relative]}
      }
    )
  end

  def check_student_observations
    student_observations.each do |obs|
      if empty_html?( obs.content ) || !students.include?( obs.student )
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
        if student_observations.none?{ |obs| obs.student_id == student.id }
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

  def restriction_message
    if !visible_to_students || !visible_to_guardians
      restrictions = []
      restrictions << "guardians" if !visible_to_guardians
      restrictions << "students" if !visible_to_students

      return "Not visible to #{restrictions.join(' or ')}"
    end
  end

  private

  def empty_html? (html_content)
    sanitized_content = Sanitize.clean( html_content, elements: ['img'] )
    return sanitized_content.blank?
  end

  def self.search(query)
    query = query.strip
    query = "%#{SqlHelper::escapeWildcards(query)}%"
    where { title.like query }
  end

  def self.has_tag(tag_id)
    where{ id.in( Post.select{id}.joins{ tags }.where{ tags.id == tag_id } ) }
  end

  def self.has_student(student_id)
    where{ id.in( Post.select{id}.joins{ students }.where{ students.id == student_id } ) }
  end

  def self.has_group(group_id)
    where{ id.in( Post.select{id}.joins{ students.groups }.where{ groups.id == group_id } ) }
  end

  def self.date_from(date)
    begin
      date = DateTime.strptime( "#{date}+5:30", '%d-%m-%Y%z' )
    rescue
      return self.scoped
    end

    where{ created_at >= date }
  end

  def self.date_to(date)
    begin
      date = DateTime.strptime( "#{date}+5:30", '%d-%m-%Y%z' ) + 1.day
    rescue
      return self.scoped
    end

    where{ created_at < date }
  end
end