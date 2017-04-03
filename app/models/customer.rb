class Customer
  
  ############################
  #     Instance Methods     #
  ############################
  
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer?t=100"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    return data["ApiItemResponseOfApiCustomerC9S9lUui"]["Item"]
    
#    customers = Customer.all(auth_token, yard_id)
#    customers.find {|customer| customer['Id'] == customer_id}
  end
  
  def self.name_by_id(auth_token, yard_id, customer_id)
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    unless customer.blank?
      return "#{customer['FirstName']} #{customer['LastName']}"
    else
      return "Customer"
    end
  end
  
#  def self.find_by_id(auth_token, yard_id, customer_id)
#    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
#    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}"
#    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
#    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
#    return data["ApiItemResponseOfApiTicketHead0UdNujZ0"]["Item"]
#  end
  
  def self.search(auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer?q=#{query_string}&t=100")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    Rails.logger.info "***********************************xml content: #{xml_content}"
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
  def self.create(auth_token, yard_id, customer_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer"
    new_guid = SecureRandom.uuid
    payload = {
      "Address1"=> customer_params[:address_1], 
      "Address2"=> customer_params[:address_2], 
      "BuyTaxCode"=>nil, 
      "CheckAddress1"=>"", 
      "CheckAddress2"=>"", 
      "CheckCity"=>"", 
      "CheckName"=>"", 
      "CheckPayTo"=>"", 
      "CheckState"=>"", 
      "CheckZip"=>"", 
      "City"=> customer_params[:city], 
      "Company"=> customer_params[:company], 
      "Country"=>"", 
      "CurrencyId"=>"00000000-0000-0000-0000-000000000000", 
      "CustomerNumber"=>"", 
      "Extension"=>"", 
      "FirstName"=> customer_params[:first_name], 
      "Id"=>new_guid, 
      "IdExpires"=> customer_params[:id_expiration], 
      "IdNumber"=> customer_params[:id_number], 
      "IdState"=> customer_params[:id_state], 
      "IsDisabled"=>"false", 
      "LastName"=> customer_params[:last_name], 
      "MiddleName"=>"", 
      "PayToCompany"=>nil, 
      "PayToFirstName"=>nil, 
      "PayToId"=>"48ea7fec-9283-4da5-b2f2-9900d3133fac", 
      "PayToLastName"=>nil, 
      "Phone"=> customer_params[:phone], 
      "SellTaxCode"=>nil, 
      "State"=> customer_params[:state], 
      "TaxCollection"=> [
          {
            "CustomerId"=>new_guid, 
            "Id"=>SecureRandom.uuid, 
            "IsBuySide"=>"true", 
            "IsTaxEligible"=>"false", 
            "OverrideTaxRate"=>"0", 
            "SalesTaxId"=>"08bde472-dea4-48a5-92c4-15429307bba8", 
            "TaxName"=>"PST", "TaxPercent"=>"8.00"
          }
        ], 
      "Zip"=> customer_params[:zip]
      }
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data["ApiItemResponseOfApiCustomerC9S9lUui"]["Success"]
    return data["ApiItemResponseOfApiCustomerC9S9lUui"]
  end
  
  def self.update(auth_token, yard_id, customer_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer"
    payload = {
      "Address1"=> customer_params[:address_1], 
      "Address2"=> customer_params[:address_2], 
      "BuyTaxCode"=>nil, 
      "CheckAddress1"=>"", 
      "CheckAddress2"=>"", 
      "CheckCity"=>"", 
      "CheckName"=>"", 
      "CheckPayTo"=>"", 
      "CheckState"=>"", 
      "CheckZip"=>"", 
      "City"=> customer_params[:city], 
      "Company"=> customer_params[:company], 
      "Country"=>"", 
      "CurrencyId"=>"00000000-0000-0000-0000-000000000000", 
      "CustomerNumber"=>"", 
      "Extension"=>"", 
      "FirstName"=> customer_params[:first_name], 
      "Id"=> customer_params[:id], 
      "IdExpires"=> customer_params[:id_expiration], 
      "IdNumber"=> customer_params[:id_number],
      "IdState"=> customer_params[:id_state], 
      "IsDisabled"=>"false", 
      "LastName"=> customer_params[:last_name], 
      "MiddleName"=>"", 
      "PayToCompany"=>nil, 
      "PayToFirstName"=>nil, 
      "PayToId"=>"48ea7fec-9283-4da5-b2f2-9900d3133fac", 
      "PayToLastName"=>nil, 
      "Phone"=> customer_params[:phone], 
      "SellTaxCode"=>nil, 
      "State"=> customer_params[:state], 
      "TaxCollection"=> customer_params[:tax_collection], 
      "Zip"=> customer_params[:zip]
      }
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data["ApiItemResponseOfApiCustomerC9S9lUui"]["Success"]
    return data["ApiItemResponseOfApiCustomerC9S9lUui"]
  end
  
  def self.default_cust_pic_id(customer_id, yard_id)
    customer_photos = CustPic.where(cust_nbr: customer_id, yardid: yard_id, event_code: "Customer Photo")
    unless customer_photos.blank?
      return customer_photos.last.id
    else
      photo_id_pics = CustPic.where(cust_nbr: customer_id, yardid: yard_id, event_code: "Photo ID")
      unless photo_id_pics.blank?
        return photo_id_pics.last.id
      else
        return nil
      end
    end
  end
  
  def self.default_cust_pic(customer_id, yard_id)
    customer_photos = CustPic.where(cust_nbr: customer_id, yardid: yard_id, event_code: "Customer Photo")
    unless customer_photos.blank?
      return customer_photos.last
    else
      photo_id_pics = CustPic.where(cust_nbr: customer_id, yardid: yard_id, event_code: "Photo ID")
      unless photo_id_pics.blank?
        return photo_id_pics.last
      else
        return nil
      end
    end
  end
  
  def self.tickets(status, auth_token, yard_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}/tickets/#{status}?d=120&t=50"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.paid_tickets(auth_token, yard_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}/tickets/3?d=120&t=50"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.paid_tickets_by_days(auth_token, yard_id, customer_id, days)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}/tickets/3?d=#{days}&t=50"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.paid_tickets_by_date(auth_token, yard_id, customer_id, start_date, end_date)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/customer/#{customer_id}/tickets/3/bydate?startdate=#{start_date}T00:00:00&enddate=#{end_date}T23:59:59&t=50"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
#  def self.paid_tickets_total(auth_token, yard_id, customer_id)
#    paid_tickets = Ticket.search(3, auth_token, yard_id, company_name)
#    paid_tickets = Customer.paid_tickets(auth_token, yard_id, customer_id)
#    total = 0
#    paid_tickets.each do |paid_ticket|
#      total = total + Ticket.total_paid(auth_token, yard_id, paid_ticket["Id"])
#    end
#    return total
#  end
#  
#  #  def paid_tickets_total_this_week(auth_token, yard_id, customer_id)
#  def self.paid_tickets_total_this_week(auth_token, yard_id, company_name)
#    paid_tickets = Ticket.search_this_week(3, auth_token, yard_id, company_name)
#    total = 0
#    Rails.logger.info paid_tickets.count
#    paid_tickets.each do |paid_ticket|
#      total = total + Ticket.total_paid(auth_token, yard_id, paid_ticket["Id"])
#    end
#    return total
#  end
  
end