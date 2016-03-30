class User < ActiveRecord::Base
  ROLES = %w[customer admin].freeze

  attr_accessor :password
  before_save :prepare_password
#  after_create :generate_token, if: :admin?
  
  has_one :access_token
  has_one :user_setting
  
  after_commit :create_user_settings, :on => :create
  
  validates_presence_of :role, :message => 'Please select type of user.'
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  
  ############################
  #     Instance Methods     #
  ############################
  
  def generate_token
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_token
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 24.hours)
  end
  
  def generate_scrap_dragon_token(user, pass)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_scrap_dragon_token(user, pass)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 12.hours)
  end
  
  def yards
    Yard.find_all(self)
  end
  
  def create_user_settings
    UserSetting.create(user_id: id, show_thumbnails: customer? ? true : false)
  end
  
  def show_thumbnails?
    user_setting.show_thumbnails?
  end
  
  def show_ticket_thumbnails?
    user_setting.show_ticket_thumbnails?
  end
  
  def show_customer_thumbnails?
    user_setting.show_customer_thumbnails?
  end
  
  def images_table?
    user_setting.table_name == "images"
  end
  
  def shipments_table?
    user_setting.table_name == "shipments"
  end
  
  def admin?
    role == "admin"
  end
  
  def customer?
    role == "customer"
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.authenticate(login, pass)
    user = find_by_username(login)
    if user and user.password_hash == user.encrypt_password(pass)
      user.update_scrap_dragon_token(login, pass) unless user.customer?
      return user 
    end
  end
  
  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
  
  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end
  
end