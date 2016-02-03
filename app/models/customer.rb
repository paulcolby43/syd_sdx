class Customer
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.find_all(yard_id, auth_token)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/customer"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
  end
end