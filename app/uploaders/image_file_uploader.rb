# encoding: utf-8

class ImageFileUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # Create different versions of your uploaded files:
  version :thumb, if: :ready_to_process? do
    process :rotate
    process :cover
#    process :resize_to_fit => [320, 240]
    process :resize_to_fit => [320, 240]
    process :convert => :jpg

    def full_filename (for_file = model.source.file)
      super.chomp(File.extname(super)) + '.jpg'
    end
  end
  
  version :large, if: :ready_to_process? do
    process :rotate
#    process :resize_to_fit => [2000, 2000]
    process :caption, :if => :should_process_caption?
    process :contract, :if => :should_process_contract?
  end
  
  def rotate
    manipulate! do |image|
      image.auto_orient
    end
  end
  
  def cover
    manipulate! do |frame, index|
      frame if index.zero? # take only the first page of the pdf file
    end
  end
  
  def caption
    # top caption
    manipulate! do |source|
      txt = Magick::Draw.new
      txt.pointsize = 20
      txt.font_family = "Impact"
      txt.gravity = Magick::NorthGravity
      txt.stroke = "#000000"
      txt.fill = "#F3F315"
      txt.font_weight = Magick::BoldWeight
      caption = "#{model.customer_name} #{Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S")} \\n Ticket: #{model.ticket_number} Event: #{model.event_code}"
      source.annotate(txt, 0, 0, 0, 20, caption)
    end

    # lower captions
    unless model.commodity_name.blank?
      manipulate! do |source|
        txt = Magick::Draw.new
        txt.pointsize = 20
        txt.font_family = "Impact"
        txt.gravity = Magick::SouthWestGravity
        txt.stroke = "#000000"
        txt.fill = "#F3F315"
        txt.font_weight = Magick::BoldWeight
        name = "#{model.commodity_name}"
        source.annotate(txt, 0, 0, 0, 20, name)
      end
    end
    unless model.weight.blank?
      manipulate! do |source|
        txt = Magick::Draw.new
        txt.pointsize = 20
        txt.font_family = "Impact"
        txt.gravity = Magick::SouthEastGravity
        txt.stroke = "#000000"
        txt.fill = "#F3F315"
        txt.font_weight = Magick::BoldWeight
        name = "Weight: #{model.weight}"
        source.annotate(txt, 0, 0, 0, 20, name)
      end
    end
  end
  
  def contract
    # top caption
    manipulate! do |source|
      txt = Magick::Draw.new
      txt.pointsize = 10
      txt.font_family = "Helvetica"
      txt.gravity = Magick::NorthGravity
      txt.fill = "black"
#      txt.stroke = "#000000"
#      txt.fill = "#F3F315"
      txt.font_weight = Magick::LighterWeight
      unless model.user.company.jpegger_contract.blank?
        caption = "#{model.user.company.jpegger_contract.verbiage}" 
      else
        caption = "Contract"
      end
#      caption = "#{model.customer_name} #{Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S")} \\n Ticket: #{model.ticket_number} Event: #{model.event_code}"
      source.annotate(txt, 0, 0, 0, 0, caption)
    end
    
    # bottom right caption
    manipulate! do |source|
      txt = Magick::Draw.new
      txt.pointsize = 10
      txt.font_family = "Helvetica"
      txt.gravity = Magick::SouthEastGravity
      txt.fill = "black"
#      txt.stroke = "#000000"
#      txt.fill = "#F3F315"
      txt.font_weight = Magick::LighterWeight
      caption = "#{Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S")} \\n Ticket: #{model.ticket_number} \\n Customer: #{model.customer_name}"
      source.annotate(txt, 0, 0, 0, 0, caption)
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
    def extension_white_list
      %w(jpg jpeg gif png pdf)
    end
    
    ### When the move_to_cache and/or move_to_store methods return true, files will be moved (instead of copied) to the cache and store respectively. ###
    def move_to_cache
      true
    end
    def move_to_store
      true
    end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  
  protected
    # Check if it is ready
    def ready_to_process?(file)
      return model.process
    end
    
    def not_signature?(file)
      return model.event_code != "Signature"
    end
    
    def should_process_caption?(file)
      (model.class.name == "ImageFile" or model.class.name == "ShipmentFile") and model.event_code != "SIGNATURE CAPTURE"
    end
    
    def should_process_contract?(file)
      (model.class.name == "ImageFile" or model.class.name == "ShipmentFile") and model.event_code == "SIGNATURE CAPTURE"
    end

end
