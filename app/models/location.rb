class Location
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.containers(auth_token, location_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/containersbylocation?locationId=#{location_id}"
    
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
      
    Rails.logger.info "Location.containers response: #{response}"
    data= Hash.from_xml(response)
    unless data["ApiGetDispatchContainersByLocationIdResponse"].blank? or data["ApiGetDispatchContainersByLocationIdResponse"]["DispatchContainers"].blank? or data["ApiGetDispatchContainersByLocationIdResponse"]["DispatchContainers"]["DispatchContainerInformation"].blank?
      if data["ApiGetDispatchContainersByLocationIdResponse"]["DispatchContainers"]["DispatchContainerInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiGetDispatchContainersByLocationIdResponse"]["DispatchContainers"]["DispatchContainerInformation"]]
      else
        return data["ApiGetDispatchContainersByLocationIdResponse"]["DispatchContainers"]["DispatchContainerInformation"]
      end
    else
      return []
    end
  end
  
end