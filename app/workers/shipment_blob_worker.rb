class ShipmentBlobWorker
  include Sidekiq::Worker
  
  def perform(shipment_file_id)
    shipment_file = ShipmentFile.find(shipment_file_id)
    shipment_file.update_attribute(:process, true)
    shipment_file.file.recreate_versions!

    # Create blob
    if shipment_file.file.content_type.start_with? 'image'
      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + shipment_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + shipment_file.file_url(:large).to_s).first.to_blob
    else # Assume only pdf's for now
      thumbnail_image_blob_data = Magick::Image::read(Rails.root.to_s + "/public" + shipment_file.file_url(:thumb).to_s).first.to_blob
      large_image_blob_data = open(shipment_file.file.path).read
    end
    
    blob = Blob.create(:preview => thumbnail_image_blob_data, :jpeg_image => large_image_blob_data, :sys_date_time => shipment_file.created_at)

    # Create shipment
    time_stamp = shipment_file.created_at.in_time_zone("Eastern Time (US & Canada)")
    shipment = Shipment.create(:file_name => File.basename(shipment_file.file_url), :branch_code => shipment_file.branch_code, :yardid => shipment_file.yard_id, :ticket_nbr => shipment_file.ticket_number,
      :container_nbr => shipment_file.container_number, :booking_nbr => shipment_file.booking_number, :contr_nbr => shipment_file.contract_number, :blob_id => blob.id, :camera_name => shipment_file.user.email, :camera_group => "Scrap Yard Dog",
      :sys_date_time => time_stamp, :event_code => shipment_file.event_code, :cust_nbr => shipment_file.customer_number, :hidden => shipment_file.hidden)
    
    # Save new shipment_file data
    shipment_file.shipment_id = shipment.id
    shipment_file.blob_id = blob.id

    shipment_file.save
  end
end