class Image < ActiveRecord::Base

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'images_data'

  belongs_to :blob
  
  UNRANSACKABLE_ATTRIBUTES = ["slave_seq", "capture_seq_nbr", "sys_seq_nbr", "image_delayed", "slave_seq", "needs_forward", "slave_ip", "initials", 
    "vector_sig", "ocr_processed", "file_name_saved", "blob_id"]

  def self.ransackable_attributes(auth_object = nil)
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end
  
  #############################
  #     Instance Methods      #
  ############################

  def jpeg_image
    blob.jpeg_image
  end

  def preview
    blob.preview
  end
  
  def jpeg_image_data_uri
    unless jpeg_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
    else
      nil
    end
  end
  
  def jpeg_image_base_64
    unless jpeg_image.blank?
      Base64.encode64(jpeg_image)
    else
      nil
    end
  end
  
  def preview_data_uri
    unless preview.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview)}"
    else
      nil
    end
  end
  
  def preview_base_64
    unless preview.blank?
      Base64.encode64(preview)
    else
      nil
    end
  end
  
  def is_customer_image(customer_name)
    Image.where(ticket_nbr: ticket_nbr, cust_name: customer_name).exists?
  end
  
  def signature?
    event_code == "Signature"
  end
  
  def pdf?
    unless jpeg_image.blank?
      blob.jpeg_image[0..3] == "%PDF" 
    else
      return false
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.proper_yardid(current_yard_id)
    where(yardid: current_yard_id)
  end
  
  private
  
  def self.ransackable_scopes(auth_object = nil)
    ["proper_yardid"]
  end
  
end