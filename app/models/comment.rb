class Comment < ActiveRecord::Base
  attr_accessible :content

  belongs_to :author, polymorphic: true
  belongs_to :post

  validates :author, presence: true
  validates :post, presence: true
  validates :content, presence: true

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end
end