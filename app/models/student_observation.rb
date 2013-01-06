class StudentObservation < ActiveRecord::Base
  attr_accessible :student_id, :content

  belongs_to :post, inverse_of: :student_observations
  belongs_to :student

  validates :post, presence: true
  validates :student, presence: true
  validates :content, presence: true
end