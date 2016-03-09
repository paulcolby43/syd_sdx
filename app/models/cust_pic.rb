class CustPic < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :capture_seq_nbr, :blob_id, :camera_name, :camera_group, :sys_date_time, :location,
#    :branch_code, :cust_nbr, :event_code, :ticket_nbr, :contr_nbr, :booking_nbr, :container_nbr, :cust_name, :thumbnail

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'CUST_PICS_data'
  
  belongs_to :blob

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
  
  def customer_photo?
    event_code == "Customer Photo"
  end
  
  def photo_id?
    event_code == "Photo ID"
  end
  
  def leads_online_code
    if customer_photo?
      "C"
    elsif photo_id?
      "I"
    else
      "C"
    end
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

  ### SEARCH WITH RANSACK ###
  def self.ransack_search(query, sort, direction)
    search = CustPic.ransack(query)
    search.sorts = "#{sort} #{direction}"
    cust_pics = search.result

    return cust_pics
  end
  
end