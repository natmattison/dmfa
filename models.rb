class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
 
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
 
  def cache_dir
    "#{Dir.pwd}/tmp/uploads"
  end
  
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process :resize_to_fit => [800, 800]

  version :thumb do
    process resize_to_fill: [280, 280]
  end

end


class Painting < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  def next
    Painting.where('id > ?', self.id).pluck(:id).min
  end
  
  def previous
    Painting.where('id < ?', self.id).pluck(:id).max
  end

end
