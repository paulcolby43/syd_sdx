class Trip
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.dispatch_info_by_user_guid(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/trips"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    return data["MobileDispatchInformation"]
  end
  
  def self.all_trips(dispatch_information)
    if dispatch_information["Trips"]["MobileDispatchTripInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [dispatch_information["Trips"]["MobileDispatchTripInformation"]]
    else # Array of results returned
      return dispatch_information["Trips"]["MobileDispatchTripInformation"]
    end
  end
  
  def self.find_all_by_user_guid(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/dispatch/trips"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    if data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"]]
    else # Array of results returned
      return data["MobileDispatchInformation"]["Trips"]["MobileDispatchTripInformation"]
    end
  end
  
  def self.find(auth_token, trip_id)
    trips = Trip.find_all_by_user_guid(auth_token)
    # Find trip within array of hashes
    trip = trips.find {|trip| trip['Id'] == trip_id}
    return trip
  end
  
  def self.tasks(trip)
    if trip["Tasks"]["MobileDispatchTaskInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [trip["Tasks"]["MobileDispatchTaskInformation"]]
    else # Array of results returned
      return trip["Tasks"]["MobileDispatchTaskInformation"]
    end
  end
  
  def self.all_trucks(dispatch_information)
    if dispatch_information["Trucks"].is_a? Hash # Only one result returned, so put it into an array
      return [dispatch_information["Trucks"]]
    else # Array of results returned
      return dispatch_information["Trucks"]
    end
  end
  
  def self.workorders(trip)
    if trip['WorkOrders']['MobileWorkOrderInformation'].is_a? Hash # Only one result returned, so put it into an array
      return [trip['WorkOrders']['MobileWorkOrderInformation']]
    else
      return trip['WorkOrders']['MobileWorkOrderInformation']
    end
  end
  
end