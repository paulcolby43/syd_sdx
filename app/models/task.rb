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
    api_url = "https://#{user.company.dragon_api}/api/dispatch/updatetaskdetails"
    
    payload = {
          "Id" => task[:id],
          "Notes" => task[:notes],
          "StartingMileage" => task[:starting_mileage],
          "EndingMileage" => task[:ending_mileage],
          "TaskStatus" => task[:status]
          }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Task.update json encoded payload: #{json_encoded_payload}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml", :content_type => 'application/json'},
      payload: json_encoded_payload)
      
#      Rails.logger.info "Task.update response: #{response}"
      data = Hash.from_xml(response)
      return data["ApiUpdateDispatchTaskDetailsResponse"]
  end
  
  def self.add_container(auth_token, task_id, container_id, latitude, longitude)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/containerxlink"
    
    payload = {
          "DispatchTaskId" => task_id,
          "ContainerId" => container_id,
          "IsUpdateRequired" => "true",
          "MobileUpdateType" => "0", # Add container - mobileupdateType is enumerated {0,1,2} for add,update,delete
          "EntryDate" => Time.now.utc.iso8601, # Remove the UTC from the end
          "latitude" => latitude.blank? ? 0 : latitude,
          "longitude" => longitude.blank? ? 0 : longitude
          }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Task.remove_container json encoded payload: #{json_encoded_payload}"

    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml", :content_type => 'application/json'},
      payload: json_encoded_payload)
    
#    Rails.logger.info "Task.add_container response: #{response}"
    data = Hash.from_xml(response)
    return data["UpdateMobileDispatchContainerXLinkResponse"]
  end
  
  def self.update_container(auth_token, task_id, container_id, latitude, longitude)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/containerxlink"
    
    payload = {
          "DispatchTaskId" => task_id,
          "ContainerId" => container_id,
          "IsUpdateRequired" => "true",
          "MobileUpdateType" => "1", # Update container - mobileupdateType is enumerated {0,1,2} for add,update,delete
          "EntryDate" => Time.now.utc.iso8601, # Remove the UTC from the end
          "latitude" => latitude.blank? ? 0 : latitude,
          "longitude" => longitude.blank? ? 0 : longitude
          }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Task.update_container json encoded payload: #{json_encoded_payload}"

    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml", :content_type => 'application/json'},
      payload: json_encoded_payload)
    
#    Rails.logger.info "Task.update_container response: #{response}"
    data = Hash.from_xml(response)
    return data["UpdateMobileDispatchContainerXLinkResponse"]
  end
  
  def self.remove_container(auth_token, task_id, container_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/containerxlink"
    
    payload = {
          "DispatchTaskId" => task_id,
          "ContainerId" => container_id,
          "IsUpdateRequired" => "true",
          "MobileUpdateType" => "2", # Remove container
          "EntryDate" => Time.now.utc.iso8601 # Remove the UTC from the end
          }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Task.remove_container json encoded payload: #{json_encoded_payload}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml", :content_type => 'application/json'},
      payload: json_encoded_payload)
    
#    Rails.logger.info "Task.remove_container response: #{response}"
    data = Hash.from_xml(response)
    return data["UpdateMobileDispatchContainerXLinkResponse"]
  end
  
  def self.create_new_container(auth_token, task_id, container_params)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/addcontainer"
    
    payload = {
          "TaskId" => task_id,
          "DispatchContainerTypeId" => container_params[:container_type_id],
          "DispatchContainerStatus" => 0,
          "Description" => container_params[:description],
          "UserDispatchContainerNumber" => container_params[:container_number],
          "TagNumber" => container_params[:tag_number],
          "latitude" => container_params[:latitude],
          "longitude" => container_params[:longitude]
          }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Task.create_new_container json encoded payload: #{json_encoded_payload}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml", :content_type => 'application/json'},
      payload: json_encoded_payload)
    
#    Rails.logger.info "Task.create_new_container response: #{response}"
    data = Hash.from_xml(response)
    return data["ApiAddDispatchContainerResponse"]
  end
  
  def self.full_address(task)
    unless (task['CustomerAddress1'].blank? and task['CustomerAddressCity'].blank? and task['CustomerAddressState'].blank? and task['CustomerAddressZip'].blank?)
      "#{task['CustomerAddress1']}<br>#{task['CustomerAddress2'].blank? ? '' : task['CustomerAddress2'] + '<br>'} #{task['CustomerAddressCity']} #{task['CustomerAddressState']} #{task['CustomerAddressZip']}"
    end
  end
  
end