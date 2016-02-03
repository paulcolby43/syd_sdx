class Yard
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token)
    api_url = "https://71.41.52.58:50002/api/user/yard"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"]
  end
end