class Ticket
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(status, auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?d=60&t=1000"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
  end
  
  def self.find_by_id(status, auth_token, yard_id, ticket_id)
    status = 'held' if status == 'Hold'
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?d=60&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].find {|ticket| ticket['Id'] == ticket_id}
  end
  
  def self.search(status, auth_token, yard_id, query_string)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=60&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.next_available_number(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket/nextnumber"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemResponseOfApiUniqueNumbermHEMxW_SG"]["Item"]["Value"]
  end
  
  
  def self.units_of_measure(auth_token)
    api_url = "https://71.41.52.58:50002/api/uom"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiUnitOfMeasureia6G0PzH"]["Items"]["ApiUnitOfMeasure"]
  end
  
  def self.create(auth_token, yard_id, customer_id, guid)
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    ticket_number = Ticket.next_available_number(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket"
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
  
  def self.update(auth_token, yard_id, customer_id, guid, ticket_number, status)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket"
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "TicketHead" => {
          "Id" => guid,
          "YardId" => yard_id,
          "CustomerId" => customer_id,
          "FirstName" => customer['FirstName'],
          "LastName" => customer['LastName'],
          "Company" => customer['Company'],
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
  
  def self.add_item(auth_token, yard_id, ticket_id, commodity_id, gross, tare, net, price, amount)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket/item"
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
  
  def self.update_item(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket/item"
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
  
  def self.void_item(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket/item/void"
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
  
end