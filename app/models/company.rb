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
  
  #############################
  #     Class Methods         #
  #############################
end