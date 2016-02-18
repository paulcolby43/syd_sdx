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
    
    data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
  end
  
  def self.find_by_id(status, auth_token, yard_id, ticket_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?d=60&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
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
  
  def self.create(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/ticket"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"},
      payload: {
        "CurrentUserId" => "91560F2C-C390-45B3-B0DE-B64C2DA255C5",
        "TicketHead" => {"Id" =>"43218929-4c3b-49da-bfcb-4f4996bf14c8",
        "YardId" => "1612c2ea-4891-4f5a-84f6-b8c5f73ceb7c",
        "CustomerId" => "00000000-0000-0000-0000-000000000000",
        "FirstName" => "",
        "LastName" => "",
        "Company" => "A Valued Customer",
        "PayToId" => "00000000-0000-0000-0000-000000000000",
        "TicketNumber" => 11539,
        "Status" => 0,
        "CurrencyId" => "ce98ebe1-c6e7-4c97-b8bb-e026897e982a",
        "DateClosed" => "2016-02-09T22:01:30.217",
        "DateCreated" => "2016-02-09T22:00:55"}
        })
      
      Rails.logger.info response
#    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, payload: {})
  end
  
end