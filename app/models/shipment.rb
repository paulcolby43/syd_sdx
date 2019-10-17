class Shipment < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :capture_seq_nbr, :blob_id, :camera_name, :camera_group, :sys_date_time, :location,
#    :branch_code, :cust_nbr, :event_code, :ticket_nbr, :contr_nbr, :booking_nbr, :container_nbr, :cust_name, :thumbnail

  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'shipments_data'
  
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
  
  def preview_data_uri
    unless preview.blank?
      "data:image/jpg;base64, #{Base64.encode64(preview)}"
    else
      nil
    end
  end

  ### SEARCH ARCHIVES WITH RANSACK ###
  def self.search_mounted_archives(query)
    shipments = []
    MountedArchive.all.each do |mounted_archive|
      if mounted_archive.client_active? # Check to see if able to successfully connect to mounted archive database
        connect_database(mounted_archive)
        search = Shipment.ransack(query)
        shipments << search.result
      end
    end
    establish_connection :development
    return shipments
  end

  def is_customer_shipment(customer_name)
    Shipment.where(ticket_nbr: ticket_nbr, cust_name: customer_name).exists?
  end

#  def check_or_define_thumbnail
#    if thumbnail.blank?
#      unless Shipment.where(ticket_nbr: ticket_nbr, location: location, thumbnail: true).exists?
#        thumbnail_shipment = Shipment.where(ticket_nbr: ticket_nbr, location: location).first
#        thumbnail_shipment.update_attribute(:thumbnail, true)
#      end
#    end
#  end

#  def thumbnail_shipment
#    thumbnail_shipment = Shipment.where(ticket_nbr: ticket_nbr, thumbnail: true)
#    unless thumbnail_shipment.blank?
#      thumbnail_shipment.first
#    else
#      nil
#    end
#  end

  #############################
  #     Class Methods         #
  #############################
  
  # Open and read jpegger shipment preview page, over ssl
  def Shipment.preview(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?preview=y&table=shipments&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end
  
  # Open and read jpegger shipment jpeg_image page, over ssl
  def Shipment.jpeg_image(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=shipments&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end

  def self.api_find_all_by_shipment_number(shipment_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from shipments where ticket_nbr='#{shipment_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
#    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    
    results = ""
    while response = ssl_client.sysread(1000) # Read 1000 bytes at a time
      results = results + response
#      puts response
      break if (response.include?("</RESULT>"))
    end
    
    ssl_client.close
    
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
#    data= Hash.from_xml(response) # Convert xml response to a hash
    data= Hash.from_xml(results.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
    
    unless data["RESULT"]["ROW"].blank?
      if data["RESULT"]["ROW"].is_a? Hash # Only one result returned, so put it into an array
        return [data["RESULT"]["ROW"]]
      else
        return data["RESULT"]["ROW"]
      end
    else
      return [] # No shipments found
    end
    
  end
  
  def self.api_find_by_capture_sequence_number(capture_sequence_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from shipments where capture_seq_nbr='#{capture_sequence_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
#    data= Hash.from_xml(response) # Convert xml response to a hash
    data = Hash.from_xml(response.gsub(/&/, '/&amp;')) # Convert xml response to a hash, escaping ampersands first
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No shipment found
    end

  end
  
  ### SEARCH WITH RANSACK ###
  def self.ransack_search(query, sort, direction)
    search = Shipment.ransack(query)
    search.sorts = "#{sort} #{direction}"
    shipments = search.result

    # Search through the mounted archives if any exists and current database doesn't return anything
#    if not MountedArchive.empty? and shipments.empty?
#      Shipment.search_mounted_archives(query)
#    end

    return shipments
  end

  ### SEARCH WITH RANSACK BY EXTERNAL/LAW USER ###
#  def self.ransack_search_external_user(query, sort, direction, customer_name)
#    search = Shipment.ransack(query)
#    search.sorts = "#{sort} #{direction}"
#    shipments = search.result
#
#    return shipments
#
#  end

  ### SEARCH WITH RANSACK BY EXTERNAL/LAW USER ###
  def self.ransack_search_external_user(query, sort, direction, customer_name)
    search = Shipment.ransack(query)
    search.sorts = "#{sort} #{direction}"
    shipments = []
    search.result.each do |shipment|
      if shipment.is_customer_shipment(customer_name)
        shipments << shipment
      end
    end

    return shipments
  end

end