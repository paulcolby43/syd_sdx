class Company < ActiveRecord::Base
  before_save :default_dragon_api
  before_save :default_jpegger_service_ip
  before_save :default_jpegger_service_port
  
  has_many :users
  has_many :inventories, through: :users
  
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
  
  # Set the default Jpegger service port to 3333
  def default_jpegger_service_port
    self.jpegger_service_port ||= "3333"
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
  
  #############################
  #     Class Methods         #
  #############################
end