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
  
  def self.api_find_all_by_ticket_number(ticket_number, company)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    command = "<FETCH><SQL>select * from images where ticket_nbr='#{ticket_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true

    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
    
#    socket = TCPSocket.open(host,port) # Connect to server
#    socket.send(command, 0)
#    
#    sleep 2 # Give socket a little time to send, then receive
#    
#    response = socket.recvfrom(200000)
#    
#    socket.close
    
#    Rails.logger.debug "***********response: #{response}"
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No tickets found
    end
    
#    unless response.blank?
#      response_array = response.first.split(/\r\n/)
#      response_array -= ["EOF!"] # Remove EOF element from array
#      return response_array.collect {|e| e.scan( /<([^>]*)>/).first.first} # Return just an array of capture sequence numbers
#    else
#      return nil
#    end
    
  end
  
  def self.api_find_by_capture_sequence_number(capture_sequence_number, company)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from images where capture_seq_nbr='#{capture_sequence_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true

    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
#    socket = TCPSocket.open(host,port) # Connect to server
#    socket.send(command, 0)
#    response = socket.recvfrom(200000)
#    socket.close
    
#    Rails.logger.debug "***********response: #{response}"
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No image found
    end

  end
  
end