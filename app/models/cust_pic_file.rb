class CustPicFile < ActiveRecord::Base
  
  mount_uploader :file, ImageFileUploader
  
  belongs_to :user
  belongs_to :cust_pic
  belongs_to :blob
  
  after_commit :sidekiq_blob_and_cust_pic_creation, :on => :create # To circumvent "Can't find ModelName with ID=12345" Sidekiq error, use after_commit
  
#  validates :event_code, presence: true
  
  attr_accessor :process # Virtual attribute to determine if ready to process versions
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def default_name
    self.name ||= File.basename(file_url, '.*').titleize
  end
  
  def sidekiq_blob_and_cust_pic_creation
    CustPicBlobWorker.perform_async(self.id) # Create the cust_pic record and the blob in the background
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.delete_files
    require 'pathname'
    require 'fileutils'
    
    CustPicFile.where('created_at < ? and created_at > ?', 7.days.ago, 14.days.ago).each do |cust_pic_file|
      if cust_pic_file.file.file and cust_pic_file.file.file.exists?
        pn = Pathname.new(cust_pic_file.file_url) # Get the path to the file
        cust_pic_file.remove_file! # Remove the file and its versions
        FileUtils.remove_dir "#{Rails.root}/public#{pn.dirname}" # Remove the now empty directory
      end
    end
  end
  
end
