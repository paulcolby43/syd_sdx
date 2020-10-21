#class SuspectList < ApplicationRecord
class SuspectList < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  
  mount_uploader :file, SuspectListFileUploader
  mount_uploader :zip_file, SuspectListZipFileUploader
  
  #############################
  #     Instance Methods      #
  ############################
  
  def parsed_file
    CSV.parse(File.read(file.path), :col_sep => "#{delimiter == 'comma' ? ',' : ' '}")
  end
  
  def no_header_parsed_file
    CSV.parse(File.read(file.path), :headers => true, :col_sep => "#{delimiter == 'comma' ? ',' : ' '}")
  end
  
  def csv_file_headers
    CSV.open(file.path, 'r') { |csv| csv.first }
  end
  
  def csv_file_table
    csv_table = Array.new
    CSV.foreach(file.path, headers:true, :col_sep => "#{delimiter == 'comma' ? ',' : ' '}") do |table_row|
      csv_table << table_row
    end
    return csv_table
  end
  
  def images_table?
    table == "images"
  end
  
  def shipments_table?
    table == "shipments"
  end
  
  def sidekiq_create_zip_file(yard_id)
    SuspectListImagesZipFileWorker.perform_async(self.id, yard_id)
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  
end
