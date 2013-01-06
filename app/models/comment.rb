class Comment < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user
  belongs_to :post

  validates :user, presence: true
  validates :post, presence: true
  validates :content, presence: true

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end

  def author_name
    user.name
  end

  def author_profile
    user.profile
  end
end