class Trip
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # User/driver-specific dispatch info
  def self.dispatch_info_by_user_guid(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/trips"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    return data["MobileDispatchInformation"]
  end
  
  # User/driver-specific trips
  def self.all_by_user(dispatch_information)
    unless dispatch_information.blank? or dispatch_information["Trips"].blank? or dispatch_information["Trips"]["MobileDispatchTripInformation"].blank?
      if dispatch_information["Trips"]["MobileDispatchTripInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [dispatch_information["Trips"]["MobileDispatchTripInformation"]]
      else # Array of results returned
        return dispatch_information["Trips"]["MobileDispatchTripInformation"]
      end
    else
      # No trips
      return [] 
    end
  end
  
  def self.search(auth_token, status, driver_id, start_date)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/gettrips"
    payload = {
      "statuses" => status.blank? ? [] : [status],
      "startingdate"=> start_date.blank? ? nil : "#{start_date}T00:00:00", 
      "driverId"=> driver_id
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
    payload: json_encoded_payload)
#    Rails.logger.info "Trip.search payload: #{json_encoded_payload}"
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Trip.search results: #{data}"
    unless data["ApiGetDispatchTripsResponse"].blank? or data["ApiGetDispatchTripsResponse"]["Trips"].blank? or data["ApiGetDispatchTripsResponse"]["Trips"]["DispatchTripInformation"].blank?
      if data["ApiGetDispatchTripsResponse"]["Trips"]["DispatchTripInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiGetDispatchTripsResponse"]["Trips"]["DispatchTripInformation"]]
      else
        return data["ApiGetDispatchTripsResponse"]["Trips"]["DispatchTripInformation"]
      end
    else
      # No trips
      return [] 
    end
  end
  
  def self.find(auth_token, trip_id)
    trips = Trip.search(auth_token, nil, nil, nil)
    trip = trips.find {|trip| trip['Id'] == trip_id}
    return trip
  end
  
  def self.service_request_tasks(trip)
    unless trip["Tasks"].blank? or trip["Tasks"]["DispatchTaskInformation"].blank?
      if trip["Tasks"]["DispatchTaskInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [trip["Tasks"]["DispatchTaskInformation"]]
      else # Array of results returned
        return trip["Tasks"]["DispatchTaskInformation"]
      end
    else
      return []
    end
  end
  
  def self.service_requests(trip)
    unless trip["WorkOrders"].blank? or trip["WorkOrders"]["WorkOrderTripRelatedListInformation"].blank?
      if trip["WorkOrders"]["WorkOrderTripRelatedListInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [trip["WorkOrders"]["WorkOrderTripRelatedListInformation"]]
      else # Array of results returned
        return trip["WorkOrders"]["WorkOrderTripRelatedListInformation"]
      end
    else
      return []
    end
  end
  
  def self.find_all_by_user_guid(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/trips"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    if data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"]]
    else # Array of results returned
      return data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"]
    end
  end
  
  def self.find_by_user_guid(auth_token, trip_id)
    trips = Trip.find_all_by_user_guid(auth_token)
    # Find trip within array of hashes
    trip = trips.find {|trip| trip['Id'] == trip_id}
    return trip
  end
  
  def self.find_in_trips(trips, trip_id)
    # Find trip within array of hashes
    trip = trips.find {|trip| trip['Id'] == trip_id}
    return trip
  end
  
  def self.tasks(trip)
    unless trip["Tasks"].blank? or trip["Tasks"]["MobileDispatchTaskInformation"].blank?
      if trip["Tasks"]["MobileDispatchTaskInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [trip["Tasks"]["MobileDispatchTaskInformation"]]
      else # Array of results returned
        return trip["Tasks"]["MobileDispatchTaskInformation"]
      end
    else
      return []
    end
  end
  
  def self.all_trucks(dispatch_information)
    unless dispatch_information["Trucks"].blank?
      if dispatch_information["Trucks"].is_a? Hash # Only one result returned, so put it into an array
        return [dispatch_information["Trucks"]]
      else # Array of results returned
        return dispatch_information["Trucks"]
      end
    else
      return []
    end
  end
  
  def self.workorders(trip)
    unless trip['WorkOrders'].blank? or trip['WorkOrders']['MobileWorkOrderInformation'].blank?
      if trip['WorkOrders']['MobileWorkOrderInformation'].is_a? Hash # Only one result returned, so put it into an array
        return [trip['WorkOrders']['MobileWorkOrderInformation']]
      else
        return trip['WorkOrders']['MobileWorkOrderInformation']
      end
    else
      return []
    end
  end
  
  def self.task_functions(dispatch_information)
    unless dispatch_information["TaskFunctions"].blank? or dispatch_information["TaskFunctions"]["DispatchTaskTypeFunctionInformation"].blank?
      if dispatch_information["TaskFunctions"]["DispatchTaskTypeFunctionInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [dispatch_information["TaskFunctions"]["DispatchTaskTypeFunctionInformation"]]
      else # Array of results returned
        return dispatch_information["TaskFunctions"]["DispatchTaskTypeFunctionInformation"]
      end
    else
      return []
    end
  end
  
  def self.container_types(dispatch_information)
    unless dispatch_information["ContainerTypes"].blank? or dispatch_information["ContainerTypes"]["ContainerTypeInformation"].blank?
      if dispatch_information["ContainerTypes"]["ContainerTypeInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [dispatch_information["ContainerTypes"]["ContainerTypeInformation"]]
      else # Array of results returned
        return dispatch_information["ContainerTypes"]["ContainerTypeInformation"]
      end
    else
      return []
    end
  end
  
  def self.task_type_functions(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/dispatchtasktypefunctions"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "*************Trip.task_type_functions: #{data}"
    unless data["ApiGetDispatchTaskTypeFunctionListResponse"].blank? or data["ApiGetDispatchTaskTypeFunctionListResponse"]["TaskFunctions"].blank? or data["ApiGetDispatchTaskTypeFunctionListResponse"]["TaskFunctions"]["DispatchTaskTypeFunctionInformation"].blank?
      return data["ApiGetDispatchTaskTypeFunctionListResponse"]["TaskFunctions"]["DispatchTaskTypeFunctionInformation"]
    else
      return []
    end
  end
  
  def self.create(auth_token, yard_id, driver_id, customer_id, task_type_function_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/AddServiceRequest"
    
    payload = {
      "driverId" => driver_id,
      "customerId"=> customer_id, 
      "taskTypeFunctionId"=> task_type_function_id, 
      "yardId"=> yard_id, 
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "Trip.add_service_request payload #{json_encoded_payload}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
#    Rails.logger.info "Trip.create response: #{response}"
    data= Hash.from_xml(response)
    unless data["ApiAddDispatchWorkOrderResponse"].blank?
      return data["ApiAddDispatchWorkOrderResponse"]
    else
      return nil
    end
  end
  
  def self.update_driver(auth_token, trip_id, driver_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}api/dispatch/updatetrip?tripId=#{trip_id}&driverId=#{driver_id}&voidTrip={bool}&voidWorkOrder={bool}"
    api_url = "https://#{user.company.dragon_api}/api/dispatch/updatetrip?tripId=#{trip_id}&driverId=#{driver_id}"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    
#    Rails.logger.info "Trip.update_driver response: #{response}"
    data= Hash.from_xml(response)
    unless data["ApiUpdateDispatchTripResponse"].blank?
      return data["ApiUpdateDispatchTripResponse"]
    else
      return nil
    end
  end
  
  def self.void(auth_token, trip_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/dispatch/updatetrip?tripId=#{trip_id}&voidTrip=true&voidWorkOrder=true"
    api_url = "https://#{user.company.dragon_api}/api/dispatch/updatetrip?tripId=#{trip_id}&voidTrip=true"
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    
#    Rails.logger.info "Trip.void response: #{response}"
    data= Hash.from_xml(response)
    unless data["ApiUpdateDispatchTripResponse"].blank?
      return data["ApiUpdateDispatchTripResponse"]
    else
      return nil
    end
  end
  
  def self.drivers(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/drivers"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "*************Trip.drivers: #{data}"
    unless data["ApiGetDispatchDriverListResponse"].blank? or data["ApiGetDispatchDriverListResponse"]["DriverList"].blank? or data["ApiGetDispatchDriverListResponse"]["DriverList"]["DriverListInformation"].blank?
      return data["ApiGetDispatchDriverListResponse"]["DriverList"]["DriverListInformation"]
    else
      return []
    end
  end
  
  def self.log_location(auth_token, trip_id, latitude, longitude)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/dispatch/logtriplocation"
    
    payload = {
      "Context" => nil,
      "PersistContext" => false,
      "BypassSave" => false,
      "Workstation" => "",
      "UserId" => "00000000-0000-0000-0000-000000000000",
      "TripId" => trip_id,
      "Latitude" => latitude,
      "Longitude" => longitude,  
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info "Trip.log_trip_location response: #{data}"
    unless data["ApiLogTripLocationResponse"].blank?
      return data["ApiLogTripLocationResponse"]
    else
      return nil
    end
  end
  
  def self.get_locations(auth_token, trip_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/dispatch/GetTripLocations/#{trip_id}"
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(response)
#    Rails.logger.info "*************Trip.get_locations #{data}"
    unless data["ApiGetTripLocationsResponse"].blank?
      if data["ApiGetTripLocationsResponse"]["Success"] == 'true'
        unless data["ApiGetTripLocationsResponse"]["LocationLogs"].blank? or data["ApiGetTripLocationsResponse"]["LocationLogs"]["ApiTripLocationInformation"].blank?
          return data["ApiGetTripLocationsResponse"]["LocationLogs"]["ApiTripLocationInformation"]
        else
          return []
        end
      else
        return []
      end
    else
      return []
    end
  end
  
  def self.geolocation_api_url(latitude, longitude)
    unless latitude.blank? or longitude.blank?
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
    end
  end
  
  def self.geolocation_json(latitude, longitude)
    geolocation_api_url = Trip.geolocation_api_url(latitude, longitude)
    unless geolocation_api_url.blank?
      json_data = RestClient::Request.execute(method: :get, url: geolocation_api_url, headers: {:Accept => "application/json"})
      unless json_data.blank?
        return JSON.parse(json_data, object_class: OpenStruct)
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def self.location_address(latitude, longitude)
    geolocation_json = Trip.geolocation_json(latitude, longitude)
    unless geolocation_json.blank? or geolocation_json.results.blank?
      geolocation_json.results.first.formatted_address
    end
  end
  
end