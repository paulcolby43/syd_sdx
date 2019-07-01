class Scoreboard
  
#  Returns the number of tickets created today and the number of tickets created in the last 30 days at the specified yard
  def self.tickets_created(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsCreated"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    return data["GetTicketsCreatedResponse"]
  end
  
#  Returns the number of tickets created today and the number of tickets created in the last 'x' number of days at the specified yard
  def self.tickets_created_number_of_days(auth_token, yard_id, days)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsCreated/#{days}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    return data["GetTicketsCreatedResponse"]
  end
  
  #  Returns the number of tickets that currently have a TicketStatus of Hold in the specified yard. Also returns the average hold time of tickets.
  def self.tickets_on_hold(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsOnHold"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    return data["GetTicketsOnHoldResponse"]
  end
  
end