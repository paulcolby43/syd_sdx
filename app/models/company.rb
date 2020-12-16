class Company < ActiveRecord::Base
  before_save :default_dragon_api
  before_save :default_jpegger_service_ip
  before_save :default_jpegger_service_port
  
#  after_create :create_gross_and_tare_and_signature_event_codes
  after_create :create_default_event_codes
  
  has_many :users
  has_many :inventories, through: :users
#  has_many :event_codes
  has_many :event_codes, -> { order(position: :asc) }
  
  mount_uploader :logo, LogoUploader
  
  validates_presence_of :name
  
  ############################
  #     Instance Methods     #
  ############################
  
  # Set the default dragon_api IP and port to what's set in environment variable
  def default_dragon_api
    self.dragon_api ||= "#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}"
  end
  
  # Set the default Jpegger service IP to what's set in environment variable
  def default_jpegger_service_ip
    self.jpegger_service_ip ||= "#{ENV['JPEGGER_SERVICE']}"
  end
  
  # Set the default Jpegger service port to 3332
  def default_jpegger_service_port
    self.jpegger_service_port ||= "3332"
  end
  
  def leads_online_config_settings_present?
    if leads_online_store_id.blank? or leads_online_ftp_username.blank? or leads_online_ftp_password.blank?
      return false
    else
      return true
    end
  end
  
  def full_address
    unless (address1.blank? and city.blank? and state.blank? and zip.blank?)
      "#{address1}<br>#{address2.blank? ? '' : address2 + '<br>'} #{city} #{state} #{zip}"
    end
  end
  
  def full_address_string
    unless (address1.blank? and city.blank? and state.blank? and zip.blank?)
      "#{address1}, #{address2.blank? ? '' : address2 + ','} #{city}, #{state}, #{zip}"
    end
  end
  
  def geolocation_api_url
    unless full_address_string.blank?
      "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(full_address_string)}&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
    end
  end
  
  def geolocation_json
    unless geolocation_api_url.blank?
      json_data = RestClient::Request.execute(method: :get, url: geolocation_api_url, headers: {:Accept => "application/json"})
      unless json_data.blank?
        return JSON.parse(json_data, object_class: OpenStruct)
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def latitude
    unless geolocation_json.blank? or geolocation_json.results.blank?
      geolocation_json.results.first.geometry.location.lat
    end
  end
  
  def longitude
    unless geolocation_json.blank? or geolocation_json.results.blank?
      geolocation_json.results.first.geometry.location.lng
    end
  end
  
  def image_event_codes
    event_codes.where(include_in_images: true)
  end
  
  def shipment_event_codes
    event_codes.where(include_in_shipments: true)
  end
  
  def fetch_event_codes
    event_codes.where(include_in_fetch_lists: true)
  end
  
#  def create_gross_and_tare_and_signature_event_codes
#    EventCode.create(company_id: self.id, name: 'Gross', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
#    EventCode.create(company_id: self.id, name: 'Tare', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
#    EventCode.create(company_id: self.id, name: 'Signature', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
#  end
  
  def create_default_event_codes
    
    # Standard Event Codes
    EventCode.create(company_id: self.id, name: 'Gross', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Tare', camera_class: 'A', camera_position: 'A', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Signature', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'License Plate', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Photo ID', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Car Title', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Deduction', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Other', include_in_fetch_lists: false, include_in_shipments: true, include_in_images: true)
    
    # Fetch Event Codes
    EventCode.create(company_id: self.id, name: 'On Ground', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Empty Inside #', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Empty Outside #', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Half Loaded', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Fully Loaded', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Full – Outside #', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Sealed', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    EventCode.create(company_id: self.id, name: 'Seal Close-up', include_in_fetch_lists: true, include_in_shipments: true, include_in_images: true)
    
  end
  
  def gross_event_code
    event_codes.where(name: "Gross").first
  end
  
  def tare_event_code
    event_codes.where(name: "Tare").first
  end
  
  def signature_event_code
    event_codes.where(name: ["Signature", "SIGNATURE", "SIGNATURE CAPTURE"]).first
  end
  
  def container_event_code
    event_codes.where(name: "Container").first
  end
  
  def gross_event_code_id
    unless gross_event_code.blank?
      gross_event_code.id
    else
      nil
    end
  end
  
  def tare_event_code_id
    unless tare_event_code.blank?
      tare_event_code.id
    else
      nil
    end
  end
  
  def signature_event_code_id
    unless signature_event_code.blank?
      signature_event_code.id
    else
      nil
    end
  end
  
  def container_event_code_id
    unless container_event_code.blank?
      container_event_code.id
    else
      nil
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
end