class StudentObservation < ActiveRecord::Base
  attr_accessible :student_id, :content

  before_validation :sanitize_content

  belongs_to :post, inverse_of: :student_observations
  belongs_to :student

  validates :post, presence: true
  validates :student, presence: true
  validates :content, presence: true

  def sanitize_content
    self.content = Sanitize.clean( content,
      elements: %w[a span p img em strong br ul ol li],
      attributes: {
        all: ['class'],
        'a' => ['href', 'title'],
        'img' => ['alt', 'src', 'title', 'height', 'width']
      },
      protocols: {
        'a'   => { 'href' => ['http', 'https', 'mailto', :relative] },
        'img' => {'src' => ['http', 'https', :relative]}
      }
    )
  end
end