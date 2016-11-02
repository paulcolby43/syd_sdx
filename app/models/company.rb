class Company < ActiveRecord::Base
  before_save :default_dragon_api
  
  has_many :users
  
  mount_uploader :logo, LogoUploader
  
  validates_presence_of :name
  
  ############################
  #     Instance Methods     #
  ############################
  
  # Set the default dragon_api IP and port to what's set in environment variable
  def default_dragon_api
    self.dragon_api ||= "#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}"
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