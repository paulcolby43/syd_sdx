class User < ActiveRecord::Base
  ROLES = %w[customer admin].freeze

  attr_accessor :password
  before_save :prepare_password
#  after_create :generate_token, if: :admin?
  
  has_one :access_token
  has_one :user_setting
  belongs_to :company
  
  after_commit :create_user_settings, :on => :create
  after_create :create_company
  
  validates_presence_of :role, :message => 'Please select type of user.'
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :username
  validates_presence_of :company_name
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  
  ############################
  #     Instance Methods     #
  ############################
  
  def generate_token
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
#    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_token
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: '9', password: '9'})
#    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
#    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 24.hours)
  end
  
#  def generate_scrap_dragon_token(user, pass, dragon_api)
  def generate_scrap_dragon_token(user_params)
#    api_url = "https://#{dragon_api}/token"
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/token"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user_params[:username], password: user_params[:password]})
#    JSON.parse(response)
    Rails.logger.info response
    access_token_string = JSON.parse(response)["access_token"]
    AccessToken.create(token_string: access_token_string, user_id: id, expiration: Time.now + 24.hours)
  end
  
  def update_scrap_dragon_token(user, pass, dragon_api)
    api_url = "https://#{dragon_api}/token"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {grant_type: 'password', username: user, password: pass})
#    JSON.parse(response)
    access_token_string = JSON.parse(response)["access_token"]
    access_token.update_attributes(token_string: access_token_string, expiration: Time.now + 12.hours)
  end
  
  def create_scrap_dragon_user(user_params)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/user"
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardName" => user_params[:company_name],
      "YardPhone" => user_params[:phone],
      "YardAddress1" => user_params[:address1],
      "YardAddress2" => user_params[:address2],
      "YardCity" => user_params[:city],
      "YardState" => user_params[:state]
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiUserResponse"]["Success"]
  end
  
  def create_scrap_dragon_customer_user( auth_token, user_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user/customer"
    
    payload = {
      "Id" => nil,
      "Username" => user_params[:username],
      "Password" => user_params[:password],
      "FirstName" => user_params[:first_name],
      "LastName" => user_params[:last_name],
      "Email" => user_params[:email],
      "YardId" => user_params[:yard_id],
      "CustomerIdCollection" => [user_params[:customer_guid]],
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
    return data["AddApiCustomerUserResponse"]["Success"]
  end
  
  def yards
    Yard.find_all(self)
  end
  
  def create_user_settings
    UserSetting.create(user_id: id, show_thumbnails: customer? ? true : false)
  end
  
  def create_company
    unless company_name.blank?
      company = Company.create(name: company_name)
    else
      company = Company.create(name: "User #{username} Company")
    end
    self.company_id = company.id
    self.save
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
      unless user.customer?
        user.update_scrap_dragon_token(login, pass, user.company.dragon_api) 
      else
        user.update_scrap_dragon_token('9', '9', user.company.dragon_api) # TODO: Get generic user for read-only access to tickets 
      end
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