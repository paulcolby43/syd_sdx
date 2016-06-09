class Company < ActiveRecord::Base
  before_save :default_dragon_api
  
  has_many :users
  
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
  
  #############################
  #     Class Methods         #
  #############################
end