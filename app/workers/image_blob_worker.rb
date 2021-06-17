class ImageBlobWorker
  include Sidekiq::Worker
  
  def perform(image_file_id, time_zone)
#    require "rmagick"
    image_file = ImageFile.find(image_file_id)
    image_file.update_attribute(:process, true)
    image_file.update_attribute(:time_zone, time_zone)
    image_file.file.recreate_versions!
    unless image_file.event_code_id.blank? 
      event_code = EventCode.find(image_file.event_code_id)
      event_code_name = event_code.name 
      if event_code and event_code.company.leads_online_config_settings_present?
        leads_online_string = "#{event_code.camera_class}#{event_code.camera_position}"
      else
        leads_online_string = ""
      end
    else
      event_code_name = image_file.event_code
      leads_online_string = ""
    end
    

    # Create blob
    if image_file.file.content_type.start_with? 'image'
#      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + image_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + image_file.file_url(:large).to_s).first.to_blob
    else # Assume only pdf's for now
#      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + image_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = open(image_file.file.path).read
    end
    # Only need to Base64 encode if passing it over the network
#    blob = Blob.create(:preview => Base64.encode64(thumbnail_image_blob_data), :jpeg_image => Base64.encode64(large_image_blob_data), :sys_date_time => image_file.created_at)
    
#    blob = Blob.create(:preview => thumbnail_image_blob_data, :jpeg_image => large_image_blob_data, :sys_date_time => image_file.created_at)

    require 'socket'
    host = image_file.user.company.jpegger_service_ip
    port = image_file.user.company.jpegger_service_port
#    host = ENV['JPEGGER_SERVICE']
#    port = 3333
    command = "<APPEND>
                <TABLE>images</TABLE>
                <BLOB>#{Base64.encode64(large_image_blob_data)}</BLOB>
                <TICKET_NBR>#{image_file.ticket_number}</TICKET_NBR>
                <EVENT_CODE>#{event_code_name}</EVENT_CODE>
                <LEADSONLINE>#{leads_online_string}</LEADSONLINE>
                <LOL_STORE_ID>#{image_file.user.company.leads_online_store_id}</LOL_STORE_ID>
                <FILE_NAME>#{File.basename(image_file.file_url)}</FILE_NAME>
                <BRANCH_CODE>#{image_file.branch_code}</BRANCH_CODE>
                <YARDID>#{image_file.yard_id}</YARDID>
                <CONTAINER_NBR>#{image_file.container_number}</CONTAINER_NBR>
                <BOOKING_NBR>#{image_file.booking_number}</BOOKING_NBR>
                <CONTR_NBR>#{image_file.contract_number}</CONTR_NBR>
                <CAMERA_NAME>#{"user_#{image_file.user.username}"}</CAMERA_NAME>
                <CAMERA_GROUP>Portal</CAMERA_GROUP>
                <CUST_NBR>#{image_file.customer_number}</CUST_NBR>
                <CUST_NAME>#{image_file.customer_name}</CUST_NAME>
                <TARE_SEQ_NBR>#{image_file.tare_seq_nbr}</TARE_SEQ_NBR>
                <CMDY_NBR>#{image_file.tare_seq_nbr}</CMDY_NBR>
                <CMDY_NAME>#{image_file.commodity_name}</CMDY_NAME>
                <WEIGHT>#{image_file.weight}</WEIGHT>
                <VIN>#{image_file.vin_number}</VIN>
                <TAGNBR>#{image_file.tag_number}</TAGNBR>
                <SERVICE_REQ_NBR>#{image_file.service_request_number}</SERVICE_REQ_NBR>
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

    # Create image
#    time_stamp = image_file.created_at.in_time_zone("Eastern Time (US & Canada)")
#    image = Image.create(:file_name => File.basename(image_file.file_url), :branch_code => image_file.branch_code, :yardid => image_file.yard_id, :ticket_nbr => image_file.ticket_number,
#      :container_nbr => image_file.container_number, :booking_nbr => image_file.booking_number, :contr_nbr => image_file.contract_number, :blob_id => blob.id, :camera_name => "user_#{image_file.user.username}", :camera_group => "Scrap Yard Dog",
#      :sys_date_time => time_stamp, :event_code => image_file.event_code, :cust_nbr => image_file.customer_number, :cust_name => image_file.customer_name, :hidden => image_file.hidden,
#      :tare_seq_nbr => image_file.tare_seq_nbr, :cmdy_nbr =>  image_file.tare_seq_nbr, :cmdy_name => image_file.commodity_name, :weight => image_file.weight,
#      "VIN" => image_file.vin_number, "TagNbr" => image_file.tag_number)
    
    # Save new image_file data
#    image_file.image_id = image.id
#    image_file.blob_id = blob.id
#
#    image_file.save
  end
end