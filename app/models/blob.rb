class Blob < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :jpeg_image, :preview, :sys_date_time, :blob_id

  establish_connection :jpegger
  
  self.primary_key = 'blob_id'

  has_one :image
  
end
