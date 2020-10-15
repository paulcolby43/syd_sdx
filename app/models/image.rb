class Image < ActiveRecord::Base

#  establish_connection :jpegger
#
#  self.primary_key = 'capture_seq_nbr'
#  self.table_name = 'images_data'
#
#  belongs_to :blob
#  
#  UNRANSACKABLE_ATTRIBUTES = ["slave_seq", "capture_seq_nbr", "sys_seq_nbr", "image_delayed", "slave_seq", "needs_forward", "slave_ip", "initials", 
#    "vector_sig", "ocr_processed", "file_name_saved", "blob_id"]
#
#  def self.ransackable_attributes(auth_object = nil)
#    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
#  end
#  
#  #############################
#  #     Instance Methods      #
#  ############################
#
#  def jpeg_image
#    blob.jpeg_image
#  end
#
#  def preview
#    blob.preview
#  end
#  
##  def jpeg_image(company)
##    blob.jpeg_image
##  end
#  
#  def jpeg_image_data_uri
#    unless jpeg_image.blank?
#      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
#    else
#      nil
#    end
#  end
#  
#  def jpeg_image_base_64
#    unless jpeg_image.blank?
#      Base64.encode64(jpeg_image)
#    else
#      nil
#    end
#  end
#  
#  def preview_data_uri
#    unless preview.blank?
#      "data:image/jpg;base64, #{Base64.encode64(preview)}"
#    else
#      nil
#    end
#  end
#  
#  def preview_base_64
#    unless preview.blank?
#      Base64.encode64(preview)
#    else
#      nil
#    end
#  end
#  
#  def is_customer_image(customer_name)
#    Image.where(ticket_nbr: ticket_nbr, cust_name: customer_name).exists?
#  end
#  
#  def signature?
#    event_code == "Signature"
#  end
#  
#  def pdf?
#    unless jpeg_image.blank?
#      blob.jpeg_image[0..3] == "%PDF" 
#    else
#      return false
#    end
#  end
#  
#  #############################
#  #     Class Methods         #
#  #############################
  
  # Open and read jpegger image preview page, over ssl
#  def self.preview(company, capture_sequence_number, yard_id)
#    require "open-uri"
#    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?preview=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
#    
#    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
#  end
#  
#  # Open and read jpegger image jpeg_image page, over ssl
#  def self.jpeg_image(company, capture_sequence_number, yard_id)
#    require "open-uri"
#    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
#    
#    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
#  end
#  
#  def self.jpeg_image_file(company, capture_sequence_number, yard_id)
#    require "open-uri"
#    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
#    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
#  end
#  
#  def self.proper_yardid(current_yard_id)
#    where(yardid: current_yard_id)
#  end
#  
#  def self.ransackable_scopes(auth_object = nil)
#    ["proper_yardid"]
#  end

  def self.uri(azure_url, company)
    "http://#{company.jpegger_service_ip}/#{azure_url}"
  end
  
  def self.thumbnail_uri(thumbnail_url, company)
    "http://#{company.jpegger_service_ip}/#{thumbnail_url}"
  end
  
  # Get all jpegger images for this company with this ticket number
  def self.api_find_all_by_ticket_number(ticket_number, company, yard_id)
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images/?ticket_nbr=#{ticket_number}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank?
      return JSON.parse(response)
    end
    
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>select * from images where ticket_nbr='#{ticket_number}' and yardid='#{yard_id}'</SQL><ROWS>1000</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
##    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#
#    results = ""
#    while response = ssl_client.sysread(1000) # Read 1000 bytes at a time
#      results = results + response
##      puts response
#      break if (response.include?("</RESULT>"))
#    end
#    
#    ssl_client.close
#    
##    Rails.logger.debug "***********Image.api_find_all_by_ticket_number results #{results}"
#    data= Hash.from_xml(results.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
#        return [data["RESULT"]["ROW"]]
#      else
#        return data["RESULT"]["ROW"]
#      end
#    else
#      return [] # No images found
#    end
    
  end
  
  # Get all the data for the image with this capture sequence number
  def self.api_find_by_capture_sequence_number(capture_sequence_number, company, yard_id)
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images?capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank? 
      return JSON.parse(response).first
    end
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>select * from images where capture_seq_nbr='#{capture_sequence_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#    ssl_client.close
#    
#    # Non-SSL TCP socket communication with jpegger
##    socket = TCPSocket.open(host,port) # Connect to server
##    socket.send(command, 0)
##    response = socket.recvfrom(200000)
##    socket.close
#    
##    Rails.logger.debug "***********response: #{response}"
##    data= Hash.from_xml(response.first) # Get first element of array response and convert xml response to a hash
##    data= Hash.from_xml(response) # Convert xml response to a hash
#    data= Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      return data["RESULT"]["ROW"] # SQL response comes back in <RESULT><ROW>
#    else
#      return nil # No image found
#    end

  end
  
  # Get all jpegger images for this company with this receipt number
  def self.api_find_all_by_receipt_number(receipt_number, company, yard_id)
    
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images/?receipt_nbr=#{receipt_number}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank?
      return JSON.parse(response)
    end
    
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>select * from images where receipt_nbr='#{receipt_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#    ssl_client.close
#    
##    Rails.logger.debug "*********** Image.api_find_all_by_receipt_number response: #{response}"
##    data= Hash.from_xml(response) # Convert xml response to a hash
#    data= Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
#        return [data["RESULT"]["ROW"]]
#      else
#        return data["RESULT"]["ROW"]
#      end
#    else
#      return [] # No images found
#    end
    
  end
  
  # Get first jpegger image for this company with this ticket number and event code
  def self.api_find_first_by_ticket_number_and_event_code(ticket_number, company, yard_id, event_code)
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images/?ticket_nbr=#{ticket_number}&event_code=#{event_code}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank?
      return JSON.parse(response)
    end
    
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>SELECT TOP 1 [images].* from images where ticket_nbr='#{ticket_number}' and event_code='#{event_code}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#    ssl_client.close
#    
##    Rails.logger.debug "***********Image.api_find_first_by_ticket_number_and_event_code response: #{response}"
##    data= Hash.from_xml(response.first) # Convert xml response to a hash
##    data= Hash.from_xml(response) # Convert xml response to a hash
#    data= Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      return data["RESULT"]["ROW"]
#    else
#      return nil # No image found
#    end
    
  end
  
  # Get all jpegger images for this company with this service request number
  def self.api_find_all_by_service_request_number(service_request_number, company, yard_id)
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images/?service_req_nbr=#{service_request_number}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank?
      return JSON.parse(response)
    end
    
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>select * from images where service_req_nbr='#{service_request_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#    ssl_client.close
#    
##    Rails.logger.debug "*********** Image.api_find_all_by_service_request_number response: #{response}"
##    data= Hash.from_xml(response) # Convert xml response to a hash
#    data= Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
#        return [data["RESULT"]["ROW"]]
#      else
#        return data["RESULT"]["ROW"]
#      end
#    else
#      return [] # No images found
#    end

  end
  
  # Get all jpegger images for this company with this ticket number
  def self.api_find_all_by_container_number_and_service_request_number(container_number, service_request_number, company, yard_id)
    api_url = "http://#{company.jpegger_service_ip}/api/v1/images/?service_req_nbr=#{service_request_number}&container_nbr=#{container_number}&yardid=#{yard_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json', :Accept => "application/json"}, payload: {})
    unless response.blank?
      return JSON.parse(response)
    end
    
#    require 'socket'
#    host = company.jpegger_service_ip
#    port = company.jpegger_service_port
#    
#    # SQL command that gets sent to jpegger service
#    command = "<FETCH><SQL>select * from images where container_nbr='#{container_number}' and service_req_nbr='#{service_request_number}' and yardid='#{yard_id}'</SQL><ROWS>1000</ROWS></FETCH>"
#    
#    # SSL TCP socket communication with jpegger
#    tcp_client = TCPSocket.new host, port
#    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
#    ssl_client.connect
#    ssl_client.sync_close = true
#    ssl_client.puts command
##    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
#
#    results = ""
#    while response = ssl_client.sysread(1000) # Read 1000 bytes at a time
#      results = results + response
##      puts response
#      break if (response.include?("</RESULT>"))
#    end
#    
#    ssl_client.close
#    
##    Rails.logger.debug "***********Image.api_find_all_by_container_number_and_service_request_number results #{results}"
#    data= Hash.from_xml(results.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
#    
#    unless data["RESULT"]["ROW"].blank?
#      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
#        return [data["RESULT"]["ROW"]]
#      else
#        return data["RESULT"]["ROW"]
#      end
#    else
#      return [] # No images found
#    end
    
  end
  
  def self.preview_data_uri(preview_image)
    unless preview_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview_image)}"
    else
      nil
    end
  end
  
  def self.jpeg_image_data_uri(jpeg_image)
    unless jpeg_image.blank?
      "data:image/jpg;base64, #{Base64.encode64(jpeg_image)}"
    else
      nil
    end
  end
  
  def self.latitude_and_longitude(company, capture_sequence_number, yard_id)
    require "open-uri"
#    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=images&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"

    image = Image.api_find_by_capture_sequence_number(capture_sequence_number, company, yard_id)
    url = Image.uri(image['azure_url'], company)
    
    begin
      data = Exif::Data.new(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))

      latitude = data.gps_latitude
      longitude = data.gps_longitude
      latitude_ref = data.gps_latitude_ref
      longitude_ref = data.gps_longitude_ref

      latitude_decimal = latitude.blank? ? nil : (latitude[0] + latitude[1]/60 + latitude[2]/3600).to_f.round(6)
      longitude_decimal = longitude.blank? ? nil : (longitude[0] + longitude[1]/60 + longitude[2]/3600).to_f.round(6)

      unless latitude_decimal.blank? or longitude_decimal.blank?
        return "#{latitude_decimal} #{latitude_ref},#{longitude_decimal} #{longitude_ref}"
      else
        return ""
      end
    rescue => e
#      Rails.logger.info "Image.latitude_and_longitude: #{e}"
      return ""
    end
  end
  
  def Image.google_map(center)
    return "https://www.google.com/maps/embed/v1/place?key=#{ENV['GOOGLE_MAPS_API_KEY']}&q=#{center}&zoom=16"
  end
  
  def self.multipart_create(params, company)
    api_url = "https://#{company.jpegger_service_ip}/images"
    RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: params)
  end
  
end