class CustPicBlobWorker
  include Sidekiq::Worker
  
  def perform(cust_pic_file_id)
    cust_pic_file = CustPicFile.find(cust_pic_file_id)
    cust_pic_file.update_attribute(:process, true)
    cust_pic_file.file.recreate_versions!

    # Create blob
    if cust_pic_file.file.content_type.start_with? 'image'
      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + cust_pic_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + cust_pic_file.file_url(:large).to_s).first.to_blob
    else # Assume only pdf's for now
      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + cust_pic_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = open(cust_pic_file.file.path).read
    end
    
    require 'socket'
    host = cust_pic_file.user.company.jpegger_service_ip
    port = cust_pic_file.user.company.jpegger_service_port
#    host = ENV['JPEGGER_SERVICE']
#    port = 3333
    command = "<APPEND>
                <TABLE>cust_pics</TABLE>
                <BLOB>#{Base64.encode64(large_image_blob_data)}</BLOB>
                <EVENT_CODE>#{cust_pic_file.event_code}</EVENT_CODE>
                <YARDID>#{cust_pic_file.yard_id}</YARDID>
                <CAMERA_NAME>#{"user_#{cust_pic_file.user.username}"}</CAMERA_NAME>
                <CAMERA_GROUP>Scrap Yard Dog</CAMERA_GROUP>
                <CUST_NBR>#{cust_pic_file.customer_number}</CUST_NBR>
                <VIN>#{cust_pic_file.vin_number}</VIN>
                <TAGNBR>#{cust_pic_file.tag_number}</TAGNBR>
              </APPEND>"
    
    tcp_client = TCPSocket.new host, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    ssl_client.connect
    ssl_client.sync_close = true
    ssl_client.puts command
    ssl_client.close
    
#    socket = TCPSocket.open(host,port) # Connect to server
#    socket.send(command, 0)
#    socket.close
    
#    blob = Blob.create(:preview => thumbnail_image_blob_data, :jpeg_image => large_image_blob_data, :sys_date_time => cust_pic_file.created_at)
#
#    # Create cust_pic
#    time_stamp = cust_pic_file.created_at.in_time_zone("Eastern Time (US & Canada)")
#    cust_pic = CustPic.create(:yardid => cust_pic_file.yard_id, :blob_id => blob.id, :camera_name => "user_#{cust_pic_file.user.username}", :camera_group => "Scrap Yard Dog",
#      :sys_date_time => time_stamp, :event_code => cust_pic_file.event_code, :cust_nbr => cust_pic_file.customer_number, :hidden => cust_pic_file.hidden,
#      "VIN" => cust_pic_file.vin_number, "TagNbr" => cust_pic_file.tag_number)
#    
#    # Save new cust_pic_file data
#    cust_pic_file.cust_pic_id = cust_pic.id
#    cust_pic_file.blob_id = blob.id
#
#    cust_pic_file.save
  end
end