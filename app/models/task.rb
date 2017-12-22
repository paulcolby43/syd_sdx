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
      return [] # No containers in task
    end
  end
  
  def self.update(auth_token, task)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/task"
    
    payload = {
        "MobileDispatchTaskInformation" => {
          "Id" => task[:id],
          "DispatchTripId" => task[:trip_id],
          "Notes" => task[:notes],
          "StartingMileage" => task[:starting_mileage],
          "EndingMileage" => task[:ending_mileage],
          "TaskStatus" => task[:status],
          "IsUpdateRequired" => true
          }
        }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info "Task.update json encoded payload: #{json_encoded_payload}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "MobileDispatchTaskInformation" => {
          "Id" => task[:id],
          "DispatchTripId" => task[:trip_id],
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
  
  def self.add_container(auth_token, task)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/task"
    
    current_task_containers = Task.containers(task)
    current_task_containers_collection_array = []
    unless current_task_containers.blank?
      current_task_containers.each do |current_task_container|
        container_hash = {
          "Id" => current_task_container['Id'],
          "DispatchTaskId" => task['Id'],		
          "ContainerId"	=> current_task_container['ContainerId'],		
          "Container" => current_task_container['Container'],	
          "Task"	=> current_task_container['Task'],
          "EntryDate" => current_task_container['EntryDate'],
          "IsUpdateRequired" => current_task_container['IsUpdateRequired'],
          "MobileUpdateType" => current_task_container['MobileUpdateType']
        }
        current_task_containers_collection_array << container_hash
      end
    end
    new_container_hash = {
      "Id" => SecureRandom.uuid,
      "DispatchTaskId" => task['Id'],		
      "ContainerId"	=> task['container_id'],		
      "Container" => "",	
      "Task"	=> "",
      "EntryDate" => Time.now.utc.iso8601, # Remove the UTC from the end
      "IsUpdateRequired" => true,
      "MobileUpdateType" => 0
    }
    
    current_task_containers_collection_array << new_container_hash
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "MobileDispatchTaskInformation" => {
          "Id" => task[:id],
          "DispatchTripId" => task[:trip_id],
          "MobileDispatchTaskContainerXLinkInformation" => current_task_containers_collection_array,
          "IsUpdateRequired" => true
          }
        })
      
      Rails.logger.info "Task.add_container response: #{response}"
      data= Hash.from_xml(response)
      return data["UpdateMobileDispatchTaskResponse"]
  end
  
end