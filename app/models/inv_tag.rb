class InvTag < ActiveRecord::Base
  
  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'INVTAGS_data'
  
  #############################
  #     Class Methods         #
  #############################
  
  # Open and read jpegger INVTAG image preview page, over ssl
  def self.preview(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?preview=y&table=INVTAGS&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end
  
  # Open and read jpegger INVTAG jpeg_image page, over ssl
  def self.jpeg_image(company, capture_sequence_number, yard_id)
    require "open-uri"
    url = "https://#{company.jpegger_service_ip}:#{company.jpegger_service_port}/sdcgi?image=y&table=INVTAGS&capture_seq_nbr=#{capture_sequence_number}&yardid=#{yard_id}"
    
    return open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
  end
  
  def self.api_find_all_by_ticket_number(tag_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from INVTAGS_data where ticket_nbr='#{tag_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    
    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return [] # No inv_tag found
    end

  end
  
  def self.api_find_all(company)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from INVTAGS</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    
    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
    Rails.logger.debug "***********InvTag.api_find_all response: #{response}"
    
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return [] # No inv_tag found
    end

  end
  
  def self.api_find_by_capture_sequence_number(capture_sequence_number, company, yard_id)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    
    # SQL command that gets sent to jpegger service
    command = "<FETCH><SQL>select * from INVTAGS where capture_seq_nbr='#{capture_sequence_number}' and yardid='#{yard_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    # SSL TCP socket communication with jpegger
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    response = ssl_client.sysread(200000) # Read up to 200,000 bytes
    ssl_client.close
    
#    data= Hash.from_xml(response.first) # Convert xml response to a hash
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No inv_tag found
    end

  end
  
end
