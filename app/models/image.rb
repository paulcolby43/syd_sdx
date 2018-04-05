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
  
#  def jpeg_image(company)
#    blob.jpeg_image
#  end
  
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
  
  # Open and read jpegger image preview page, over ssl
  def self.preview(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?preview=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end
  
  # Open and read jpegger image jpeg_image page, over ssl
  def self.jpeg_image(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end
  
  def self.proper_yardid(current_yard_id)
    where(yardid: current_yard_id)
  end
  
  def self.ransackable_scopes(auth_object = nil)
    ["proper_yardid"]
  end
  
  # Get all jpegger images for this company with this ticket number
  def self.api_find_all_by_ticket_number(ticket_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from images where ticket_nbr='#{ticket_number}' and yardid='#{yard_id}'</SQL><ROWS>1000</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    response = ""
    while line = ssl_client.gets
      response = response + line
      puts line
      break if (line.to_s.strip == '</RESULT>') or (line.to_s.strip == '<RESULT>EOF</RESULT>') # Last line or no results
#      break unless (line.start_with?("<ROW>") or line.include?("</RESULT>") or line.include?("\r\n"))
#      break if (line.include?("\r\n</RESULT>"))
    end
    
    ssl_client.close
    
    Rails.logger.debug "***********Image.api_find_all_by_ticket_number response: #{response}"
    data= Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No images found
    end
    
  end
  
  # Get all the data for the image with this capture sequence number
  def self.api_find_by_capture_sequence_number(capture_sequence_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from images where capture_seq_nbr='#{capture_sequence_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
    # Non-SSL TCP socket communication with jpegger
#    socket = TCPSocket.open(host,port) # Connect to server
#    socket.send(command, 0)
#    response = socket.recvfrom(200000)
#    socket.close
    
#    Rails.logger.debug "***********response: #{response}"
#    data= Hash.from_xml(response.first) # Get first element of array response and convert xml response to a hash
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"] # SQL response comes back in <RESULT><ROW>
    else
      return nil # No image found
    end

  end
  
  # Get all jpegger images for this company with this receipt number
  def self.api_find_all_by_receipt_number(receipt_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from images where receipt_nbr='#{receipt_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
    Rails.logger.debug "*********** Image.api_find_all_by_receipt_number response: #{response}"
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No images found
    end
  end
  
  # Get first jpegger image for this company with this ticket number and event code
  def self.api_find_first_by_ticket_number_and_event_code(ticket_number, company, yard_id, event_code)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>SELECT TOP 1 [images].* from images where ticket_nbr='#{ticket_number}' and event_code='#{event_code}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
    Rails.logger.debug "***********Image.api_find_first_by_ticket_number_and_event_code response: #{response}"
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No image found
    end
    
  end
  
  # Get all jpegger images for this company with this service request number
  def self.api_find_all_by_service_request_number(service_request_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from images where service_req_nbr='#{service_request_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
    Rails.logger.debug "*********** Image.api_find_all_by_service_request_number response: #{response}"
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No images found
    end
  end
  
  def self.jpeg_image_data_uri(jpeg_image)
    unless jpeg_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
    else
      nil
    end
  end
    
  
end