class Task
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.containers(task)
    unless task['ContainerXLinks'].blank? or task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation'].blank?
      if task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation'].is_a? Hash # Only one result returned, so put it into an array
        return [task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation']]
      else
        return task['ContainerXLinks']['MobileDispatchTaskContainerXLinkInformation']
      end
    else
      return []
    end
  end
  
  def self.update(auth_token, task)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/task"
    
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
      
      Rails.logger.info "Task update response: #{response}"
      data= Hash.from_xml(response)
      return data["UpdateMobileDispatchTaskResponse"]
  end
  
  def self.find_container_by_container_id(containers, container_id)
    # Find container within array of hashes
    container = containers.find {|container| container['Id'] == container_id}
    return container
  end
  
end