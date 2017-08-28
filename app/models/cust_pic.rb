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
  
  def self.table_exists?
    CustPic.connection.table_exists? 'CUST_PICS_data'
  end
  
  def self.api_find_all_by_customer_number(customer_number)
    require 'socket'
    host = ENV['JPEGGER_SERVICE']
    port = 3333
    command = "<FETCH><SQL>select * from cust_pics where cust_nbr='#{customer_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    socket = TCPSocket.open(host,port) # Connect to server
    socket.send(command, 0)
    response = socket.recvfrom(port)
    socket.close
    
    data= Hash.from_xml(response.first) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No cust_pics found
    end
    
  end
  
  def self.api_find_by_capture_sequence_number(capture_sequence_number)
    require 'socket'
    host = ENV['JPEGGER_SERVICE']
    port = 3333
    command = "<FETCH><SQL>select * from cust_pics where capture_seq_nbr='#{capture_sequence_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    socket = TCPSocket.open(host,port) # Connect to server
    socket.send(command, 0)
    response = socket.recvfrom(port)
    socket.close
    
    data= Hash.from_xml(response.first) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No cust_pic image found
    end

  end
  
end