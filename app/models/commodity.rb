class Commodity
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/commodity?t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
  end
  
  def self.find_by_id(auth_token, yard_id, commodity_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/commodity?t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"].find {|commodity| commodity['Id'] == commodity_id}
  end
  
  def self.search(auth_token, yard_id, query_string)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/commodity?q=#{query_string}&t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
    end
  end
  
end