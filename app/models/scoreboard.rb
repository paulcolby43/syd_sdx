class Scoreboard
  
#  Returns the number of tickets created today and the number of tickets created in the last 30 days at the specified yard
  def self.tickets_created(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsCreated"
    begin
      xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    rescue RestClient::ExceptionWithResponse => e
      e.response
      Rails.logger.info "Scoreboard.tickets_created exception response: #{e.response}"
      return nil
    end
    unless xml_content.blank?
      data= Hash.from_xml(xml_content)
  #    Rails.logger.info "Scoreboard.tickets_created: #{data}"
      return data["GetTicketsCreatedResponse"]
    else
      return nil
    end
  end
  
#  Returns the number of tickets created today and the number of tickets created in the last 'x' number of days at the specified yard
  def self.tickets_created_number_of_days(auth_token, yard_id, days)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsCreated/#{days}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.tickets_created_number_of_days: #{data}"
    
    return data["GetTicketsCreatedResponse"]
  end
  
  #  Returns the number of tickets that currently have a TicketStatus of Hold in the specified yard. Also returns the average hold time of tickets.
  def self.tickets_on_hold(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/ticketsOnHold"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.tickets_on_hold: #{data}"
    
    return data["GetTicketsOnHoldResponse"]
  end
  
  #  Returns the number of tickets where PaidDate is today and PaymentStatus is Paid in the specified yard. Also returns the sum of the amounts of those paid tickets.
  def self.paid_tickets_today_data(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/paidTickets"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.paid_tickets: #{data}"
    
    return data["GetPaidTicketsResponse"]
  end
  
  #  Returns a list of commodity totals by type. Since commodity type is a user defined list, we just return them all so that the consumer can decide which to use. 
  #  Along with the commodity types, it returns the weight (in LB) and dollar amount of each type purchased today. It also returns the average weight and cost over the last 30 days. 
  #  The divisor for the average division is determined based on the number of records we found, in order to prevent including days where the yard might be closed in the averaging.
  def self.commodity_totals_by_type(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/commodityTotalsByType"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.commodity_totals_by_type: #{data}"
    
    unless data["GetCommodityTotalsResponse"].blank? or data["GetCommodityTotalsResponse"]["CommodityTotals"].blank? or data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"].blank?
      if data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"]]
      else # Array of results returned
        return data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"]
      end
    else
      return []
    end
  end
  
  # The same call as Scoreboard.commodity_totals_by_type, but  can specify the number of days to go back and look for data.
  def self.commodity_totals_by_type_number_of_days(auth_token, yard_id, days)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/commodityTotalsByType/#{days}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.commodity_totals_by_type_number_of_days: #{data}"
    
    unless data["GetCommodityTotalsResponse"].blank? or data["GetCommodityTotalsResponse"]["CommodityTotals"].blank? or data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"].blank?
      if data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"]]
      else # Array of results returned
        return data["GetCommodityTotalsResponse"]["CommodityTotals"]["CommodityTotals"]
      end
    else
      return []
    end
  end
  
  # Returns the number of shipments where DateCreated is today and the ShipmentStatus is Held in the specified yard.
  def self.held_shipments_count(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/heldShipments"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.held_shipments: #{data}"
    unless data["GetHeldShipmentsResponse"].blank? or data["GetHeldShipmentsResponse"]["HeldShipments"].blank?
      return data["GetHeldShipmentsResponse"]["HeldShipments"]
    else
      return nil
    end
  end
  
  # Returns the number of shipments where DateOut is today and the ShipmentStatus is Billed or Closed in the specified yard.
  def self.sent_shipments_count(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/scoreboard/sentShipments"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.sent_shipments: #{data}"
    unless data["GetSentShipmentsResponse"].blank? or data["GetSentShipmentsResponse"]["SentShipments"].blank?
      return data["GetSentShipmentsResponse"]["SentShipments"]
    else
      return nil
    end
  end
  
  def self.held_tickets_today(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/2?d=0&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.held_tickets_today: #{data}"
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
  def self.closed_tickets_today(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/1?d=0&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.closed_tickets_today: #{data}"
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
  def self.paid_tickets_today(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/3?d=0&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Scoreboard.paid_tickets_today: #{data}"
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
end