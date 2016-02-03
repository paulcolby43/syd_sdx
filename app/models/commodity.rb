class Commodity
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.find_all(yard_id, auth_token)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/commodity"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
  end
end