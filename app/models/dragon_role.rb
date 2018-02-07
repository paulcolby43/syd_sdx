class DragonRole
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/roles"
    
    begin
      response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'})
      data= Hash.from_xml(response)
      Rails.logger.info data
      
      unless data["ArrayOfRoleInformation"].blank? or data["ArrayOfRoleInformation"]["RoleInformation"].blank?
        if data["ArrayOfRoleInformation"]["RoleInformation"].is_a? Hash # Only one result returned, so put it into an array
          return [data["ArrayOfRoleInformation"]["RoleInformation"]]
        else # Array of results returned
          return data["ArrayOfRoleInformation"]["RoleInformation"]
        end
      else
        return []
      end
    rescue => e
      Rails.logger.info "Problem calling DragonRole.all: #{e.response}"
      return []
    end
  end
  
end