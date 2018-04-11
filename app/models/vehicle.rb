class Vehicle
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.combolists(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/vehicle/combolists"
    begin
      xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
          :content_type => 'application/json', :Accept => "application/xml"})
      data= Hash.from_xml(xml_content)
      Rails.logger.info data

      return data["GetVehicleComboListsResponse"]
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.info "Vehicle.combolists call: no Dragon API"
      return nil
    end
  end
  
end