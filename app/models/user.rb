class User < ActiveRecord::Base

  attr_accessor :password
  before_save :prepare_password
  after_create :generate_token
  
  has_one :access_token
  
  ############################
  #     Instance Methods     #
  ############################
  
  def generate_token
    api_url = "https://71.41.52.58:50002/token"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_token
    api_url = "https://71.41.52.58:50002/token"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 24.hours)
  end
  
  def yards
    Yard.find_all(self)
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.authenticate(login, pass)
    user = find_by_username(login)
    if user and user.password_hash == user.encrypt_password(pass)
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