class Ticket
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(status, auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?d=30&t=1000"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
  end
  
  def self.find_by_id(status, auth_token, yard_id, ticket_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?d=30&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].find {|ticket| ticket['Id'] == ticket_id}
  end
  
  def self.search(status, auth_token, yard_id, query_string)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=30&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
end