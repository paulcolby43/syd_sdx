# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # Create different versions of your uploaded files:
  version :thumb do
    process :rotate
#    process :resize_to_fit => [320, 240]
    process :resize_to_fit => [300, 300]
#    process :convert => :jpg

#    def full_filename (for_file = model.source.file)
#      super.chomp(File.extname(super)) + '.jpg'
#    end
  end
  
#  version :large do
#    process :rotate
#    process :resize_to_fit => [2000, 2000]
#  end
  
  def rotate
    manipulate! do |image|
      image.auto_orient
    end
  end
  
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
    def extension_white_list
      %w(jpg jpeg gif png)
    end
    
    ### When the move_to_cache and/or move_to_store methods return true, files will be moved (instead of copied) to the cache and store respectively. ###
#    def move_to_cache
#      true
#    end
#    def move_to_store
#      true
#    end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  
  protected
    
end