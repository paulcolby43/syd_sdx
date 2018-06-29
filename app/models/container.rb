class Container
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all_by_dispatch_information(dispatch_information)
    unless dispatch_information['Containers'].blank? or dispatch_information['Containers']['MobileDispatchContainerInformation'].blank?
      if dispatch_information['Containers']['MobileDispatchContainerInformation'].is_a? Hash # Only one result returned, so put it into an array
        return [dispatch_information['Containers']['MobileDispatchContainerInformation']]
      else
        return dispatch_information['Containers']['MobileDispatchContainerInformation']
      end
    else
      return [] # No containers
    end
  end
  
  def self.update(auth_token, task)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/container"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "MobileDispatchTaskInformation" => {
          "Id" => task[:id],
          "Notes" => task[:notes],
          "StartingMileage" => task[:starting_mileage],
          "EndingMileage" => task[:ending_mileage],
          "TaskStatus" => task[:status],
          "IsUpdateRequired" => true
          }
        })
      
      Rails.logger.info "Container.update response: #{response}"
      data= Hash.from_xml(response)
      return data["UpdateMobileDispatchTaskResponse"]
  end
  
  def self.find_by_container_id(containers, container_id)
    # Find container within array of hashes
    container = containers.find {|container| container['Id'] == container_id}
    return container
  end
  
  def self.find_by_id(auth_token, container_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/container?containerId=#{container_id}"
    
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
      
    Rails.logger.info "Container.find_by_id response: #{response}"
    data= Hash.from_xml(response)
    unless data["ApiGetDispatchContainerResponse"].blank? or data["ApiGetDispatchContainerResponse"]["DispatchContainer"].blank?
      return data["ApiGetDispatchContainerResponse"]["DispatchContainer"]
    else
      return nil
    end
  end
  
  def self.latitude_and_longitude_by_container_id(containers, container_id)
    # Find container within array of hashes
    container = containers.find {|container| container['Id'] == container_id}
    unless container.blank? or ((container['Latitude'].blank? or container['Latitude'] == '0') and (container['Longitude'].blank? or container['Longitude'] == '0'))
      return {lat: container['Latitude'].to_f, lng: container['Longitude'].to_f, number: container['UserDispatchContainerNumber']}
    else
      nil
    end
  end
  
end