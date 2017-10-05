class InvTag < ActiveRecord::Base
  
  establish_connection :jpegger

  self.primary_key = 'capture_seq_nbr'
  self.table_name = 'INVTAGS_data'
  
  def self.api_find_all_by_ticket_number(tag_number, company)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from INVTAGS_data where ticket_nbr='#{tag_number}'</SQL><ROWS>100</ROWS></FETCH>"
    
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
  
end