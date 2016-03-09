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
    
    blob = Blob.create(:preview => thumbnail_image_blob_data, :jpeg_image => large_image_blob_data, :sys_date_time => cust_pic_file.created_at)

    # Create cust_pic
    time_stamp = cust_pic_file.created_at.in_time_zone("Eastern Time (US & Canada)")
    cust_pic = CustPic.create(:location => cust_pic_file.location, :blob_id => blob.id, :camera_name => "user_#{cust_pic_file.user.username}", :camera_group => "Scrap Yard Dog",
      :sys_date_time => time_stamp, :event_code => cust_pic_file.event_code, :cust_nbr => cust_pic_file.customer_number, :hidden => cust_pic_file.hidden,
      "VIN" => cust_pic_file.vin_number, "TagNbr" => cust_pic_file.tag_number)
    
    # Save new cust_pic_file data
    cust_pic_file.cust_pic_id = cust_pic.id
    cust_pic_file.blob_id = blob.id

    cust_pic_file.save
  end
end