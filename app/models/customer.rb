class Customer
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/customer"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
  end
  
  def self.find_by_id(auth_token, yard_id, customer_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/customer"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].find {|customer| customer['Id'] == customer_id}
  end
  
  def self.search(auth_token, yard_id, query_string)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/customer?q=#{query_string}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
end