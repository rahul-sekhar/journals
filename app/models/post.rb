class Post < ActiveRecord::Base
  attr_accessible :title, :content

  belongs_to :user

  validates :title, presence: true
  validates :user, presence: true

  def formatted_created_at
    created_at.strftime "#{created_at.day.ordinalize} %B %Y"
  end

  def author
    user.name
  end
end