class ImageFile < ActiveRecord::Base
  
  mount_uploader :file, ImageFileUploader
  
  belongs_to :user
  belongs_to :image
  belongs_to :blob
#  belongs_to :event_code
  
  after_commit :sidekiq_blob_and_image_creation, :on => :create # To circumvent "Can't find ModelName with ID=12345" Sidekiq error, use after_commit
  after_commit :save_image_location_to_container, :on => :create
  
#  validates :ticket_number, presence: true
  
  attr_accessor :process # Virtual attribute to determine if ready to process versions
  
  # Virtual attributes to look for location meta data and save to container
  attr_accessor :pin_image_location_to_container
  attr_accessor :container_id
  attr_accessor :task_id
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def default_name
    self.name ||= File.basename(file_url, '.*').titleize
  end
  
  # Create the image record and the blob in the background
  def sidekiq_blob_and_image_creation
    ImageBlobWorker.perform_async(self.id) 
  end
  
  def latitude_and_longitude
    begin
      data = Exif::Data.new(File.open(self.file.current_path))

      latitude = data.gps_latitude
      longitude = data.gps_longitude

      latitude_decimal = latitude.blank? ? nil : (latitude[0] + latitude[1]/60 + latitude[2]/3600).to_f
      longitude_decimal = longitude.blank? ? nil : (longitude[0] + longitude[1]/60 + longitude[2]/3600).to_f

      unless latitude_decimal.blank? or longitude_decimal.blank?
        return "#{latitude_decimal}, #{longitude_decimal}"
      else
        return ""
      end
    rescue => e
#      Rails.logger.info "image_file.latitude_and_longitude: #{e}"
      return ""
    end
  end
  
  def latitude
    begin
      data = Exif::Data.new(File.open(self.file.current_path))

      latitude = data.gps_latitude

      latitude_decimal = latitude.blank? ? nil : (latitude[0] + latitude[1]/60 + latitude[2]/3600).to_f

      unless latitude_decimal.blank?
        return "#{latitude_decimal}"
      else
        return ""
      end
    rescue => e
#      Rails.logger.info "image_file.latitude: #{e}"
      return ""
    end
  end
  
  def longitude
    begin
      data = Exif::Data.new(File.open(self.file.current_path))

      longitude = data.gps_longitude

      longitude_decimal = longitude.blank? ? nil : (longitude[0] + longitude[1]/60 + longitude[2]/3600).to_f

      unless longitude_decimal.blank?
        return "#{longitude_decimal}"
      else
        return ""
      end
    rescue => e
#      Rails.logger.info "image_file.longitude: #{e}"
      return ""
    end
  end
  
  def save_image_location_to_container
    if self.pin_image_location_to_container == 'true'
      Task.update_container(user.token, task_id, container_id, latitude, longitude)
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.delete_files
    require 'pathname'
    require 'fileutils'
    
    ImageFile.where('created_at < ? and created_at > ?', 7.days.ago, 14.days.ago).each do |image_file|
      if image_file.file.file and image_file.file.file.exists?
        pn = Pathname.new(image_file.file_url) # Get the path to the file
        image_file.remove_file! # Remove the file and its versions
        FileUtils.remove_dir "#{Rails.root}/public#{pn.dirname}" # Remove the now empty directory
      end
    end
  end
  
end
