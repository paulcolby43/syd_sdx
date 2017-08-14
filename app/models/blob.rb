class Blob < ActiveRecord::Base
  #  new columns need to be added here to be writable through mass assignment
#  attr_accessible :jpeg_image, :preview, :sys_date_time, :blob_id

  establish_connection :jpegger
  
  self.primary_key = 'blob_id'

  has_one :image
  
  def self.api_find_by_id(blob_id)
    require 'socket'
    host = ENV['JPEGGER_SERVICE']
    port = 3333
    command = "<FETCH><SQL>select * from blobs where blob_id='#{blob_id}'</SQL><ROWS>100</ROWS></FETCH>"
    
    socket = TCPSocket.open(host,port) # Connect to server
    socket.send(command, 0)
    response = socket.recvfrom(port)
    socket.close
    
    data= Hash.from_xml(response.first) # Convert xml response to a hash
    
    unless data["RESULT"]["ROW"].blank?
      return data["RESULT"]["ROW"]
    else
      return nil # No blob found
    end

  end
  
end
