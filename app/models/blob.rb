class Blob < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :jpeg_image, :preview, :sys_date_time, :blob_id

  establish_connection :jpegger
  
  self.primary_key = 'blob_id'

  has_one :image
  
  def self.api_find_by_id(blob_id, company)
    require 'socket'
    host = company.jpegger_service_ip
    port = company.jpegger_service_port
    command = "<FETCH><SQL>select * from blobs where blob_id='#{blob_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    
    ssl_client.puts command
    response = ssl_client.sysread(200000)
    
    ssl_client.close
    
#    Rails.logger.debug "***********Blob.api_find_by_id response: #{response}"
    
    data= Hash.from_xml(response) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No blob found
    end

  end
  
end
