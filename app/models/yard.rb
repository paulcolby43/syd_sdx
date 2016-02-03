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
  
  def self.find_by_id(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/user/yard"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"].find {|yard| yard['Id'] == yard_id}
  end
  
  def self.find_by_name(auth_token, yard_name)
    api_url = "https://71.41.52.58:50002/api/user/yard"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"].find {|yard| yard['Name'] == yard_name}
  end
end