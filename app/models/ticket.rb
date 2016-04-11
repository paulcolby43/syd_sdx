class Ticket
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(status, auth_token, yard_id)
#    status = 'held' if status == 'Hold'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=60&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  # Get all tickets for given customer ID
  def self.customer_all(status, auth_token, yard_id, query_string)
    require 'uri'
    api_url = URI.encode("https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=60&t=100")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.find_by_id(status, auth_token, yard_id, ticket_id)
    tickets = Ticket.all(status, auth_token, yard_id)
#    Rails.logger.info tickets
    tickets.find {|ticket| ticket['Id'] == ticket_id}
  end
  
  def self.search(status, auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=60&t=100")
#    api_url = URI.encode("https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=60&t=100")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  # Get next available ticket number
  def self.next_available_number(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/nextnumber"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemResponseOfApiUniqueNumbermHEMxW_SG"]["Item"]["Value"]
  end
  
  # Get Scrap Dragon units of measure
  def self.units_of_measure(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/uom"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiUnitOfMeasureia6G0PzH"]["Items"]["ApiUnitOfMeasure"]
  end
  
  # Create a new ticket
  def self.create(auth_token, yard_id, customer_id, guid)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    ticket_number = Ticket.next_available_number(auth_token, yard_id)
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
#        "CurrentUserId" => "91560F2C-C390-45B3-B0DE-B64C2DA255C5",
        "TicketHead" => {
          "Id" => guid,
          "YardId" => yard_id,
          "CustomerId" => customer_id,
          "FirstName" => customer['FirstName'],
          "LastName" => customer['LastName'],
          "Company" => customer['Company'],
          "PayToId" => "00000000-0000-0000-0000-000000000000",
          "TicketNumber" => ticket_number,
          "Status" => 2,
          "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a",
  #        "DateClosed" => "2016-02-18T22:01:30.217",
          "DateCreated" => Time.now.utc
          }
        })
      
#      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketResponse"]["Success"]
  end
  
  # Update an existing ticket
  def self.update(auth_token, yard_id, customer_id, guid, ticket_number, status)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "TicketHead" => {
          "Id" => guid,
          "YardId" => yard_id,
          "CustomerId" => customer_id,
          "FirstName" => customer.blank? ? "" : customer['FirstName'],
          "LastName" => customer.blank? ? "" : customer['LastName'],
          "Company" => customer.blank? ? "" : customer['Company'],
          "PayToId" => "00000000-0000-0000-0000-000000000000",
          "TicketNumber" => ticket_number,
          "Status" => status,
          "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a",
          "VoidedByUserId" => "91560F2C-C390-45B3-B0DE-B64C2DA255C5",
          "DateClosed" =>  "",
          "DateCreated" => Time.now.utc
          }
        })
      
      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketResponse"]["Success"]
  end
  
  # Add a line item to a ticket
  def self.add_item(auth_token, yard_id, ticket_id, commodity_id, gross, tare, net, price, amount)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    commodity_name = Commodity.find_by_id(auth_token, yard_id, commodity_id)["PrintDescription"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a", 
          "DateCreated" => Time.now.utc, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "GrossWeight" => gross,
          "Id" => SecureRandom.uuid, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "Quantity" => amount,
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
         "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
      
#      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Update line item of ticket
  def self.update_item(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    commodity_name = Commodity.find_by_id(auth_token, yard_id, commodity_id)["PrintDescription"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a", 
          "DateCreated" => Time.now.utc, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "Quantity" => amount,
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
      
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Void/remove a line item from ticket
  def self.void_item(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/void"
    commodity_name = Commodity.find_by_id(auth_token, yard_id, commodity_id)["PrintDescription"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a", 
          "DateCreated" => Time.now.utc, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "Quantity" => amount,
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Get accounts payable items for ticket (multiple items if partial payments)
  def self.acccounts_payable_items(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "********************#{data}****************"
    if data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]]
    else # Array of results returned
      # This will only be more than one if this is a preexisting ticket that had a payment split or payment was split by the device.
      return data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]
    end
  end
  
  # Pay ticket by cash
  def self.pay_by_cash(auth_token, yard_id, ticket_id, accounts_payable_id, drawer_id, amount)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem/#{accounts_payable_id}/pay"
    accounts_payable_line_item = Ticket.acccounts_payable_items(auth_token, yard_id, ticket_id).last
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=nil  if v == {"i:nil"=>"true"} }
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=""  if v == nil }
    payload = {
      "AccountsPayableLineItem" => accounts_payable_line_item,
      "PaymentMethod" => 0,
      "DrawerId" => drawer_id,
      "Check" => nil
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
      
      data= Hash.from_xml(response)
#      return data["ApiItemsResponseOfApiPayAccountsPayableLineItemResponsedmIQzVzw"]["Success"]
      return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]["Success"]
  end
  
  # Pay ticket by check
  def self.pay_by_check(auth_token, yard_id, ticket_id, accounts_payable_id, drawer_id, check_id, check_account_name, check_number, amount)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem/#{accounts_payable_id}/pay"
    accounts_payable_line_item = Ticket.acccounts_payable_items(auth_token, yard_id, ticket_id).last
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=nil  if v == {"i:nil"=>"true"} }
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=""  if v == nil }
    payload = {
      "AccountsPayableLineItem" => accounts_payable_line_item,
      "PaymentMethod" => 1,
      "DrawerId" => drawer_id,
      "Check" => { 
        "Id" => SecureRandom.uuid,
        "AccountsPayableCashierId" => nil, 
        "CheckAccountId" => check_id,
        "CheckNumber" => check_number,
        "Amount" => amount,
        "PayToTheOrderOf" => "", 
        "Memo" => "ticket ID: #{ticket_id}",
        "Company" => "",
        "Address1" => "",
        "Address2" => "",
        "City" => "",
        "State" => "",
        "Zip" => "",
        "CheckStatus" => "",
        "CheckAccountName" => check_account_name,
        "CurrencyId" => "",
        "CurrencyConversionFactor" => ""
        }
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
      
      data= Hash.from_xml(response)
#      return data["ApiItemsResponseOfApiPayAccountsPayableLineItemResponsedmIQzVzw"]["Success"]
      return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]["Success"]
  end
  
end