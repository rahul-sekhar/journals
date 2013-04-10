class Image < ActiveRecord::Base
  mount_uploader :file_name, ImageUploader

  belongs_to :post

  validates :file_name, presence: true, file_size: { maximum: 2.megabytes.to_i }

  def name
    File.basename(file_name.url)
  end

  def url
    file_name.url
  end

  def size
    file_name.size
  end
end