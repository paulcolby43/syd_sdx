class PackShipment
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # This returns shipments of any status except void.  You specify the number of results you’d like.
  def self.all(auth_token, yard_id, number)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/Shipments/#{number}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "PackShipment.all response: #{data}"
    
    unless data["GetShipmentsByStatusForMobileResponse"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].blank?
      if data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    else # No shipments found
      return []
    end
  end
  
  # Get all held shipments
  def self.all_held(auth_token, yard_id) # Held shipments
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/HeldShipments"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "PackShipment.all_held response: #{data}"
    
    unless data["GetShipmentsByStatusForMobileResponse"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].blank?
      if data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    else # No shipments found
      return []
    end
  end
  
  def self.all_held_today(auth_token, yard_id)
    held_shipments = PackShipment.all_held(auth_token, yard_id)
    held_shipments_today = []
    held_shipments.each do |shipment|
      held_shipments_today << shipment if shipment['DateCreated'].to_date == Date.today
    end
    return held_shipments_today
  end
  
  # Get a number of held shipments
  def self.number_of_held(auth_token, yard_id, number)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/HeldShipments/#{number}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "PackShipment.number_of_held response: #{data}"
    
    unless data["GetShipmentsByStatusForMobileResponse"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].blank?
      if data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    else # No shipments found
      return []
    end
  end
  
  def self.find_by_id(auth_token, yard_id, pack_shipment_id)
    pack_shipments = PackShipment.all(auth_token, yard_id)
    # Find pack shipment within array of hashes
    pack_shipment = pack_shipments.find {|ps| ps['Id'] == pack_shipment_id}
    return pack_shipment
  end
  
  def self.find(auth_token, yard_id, pack_shipment_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/GetShipmentById?shipId=#{pack_shipment_id}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.find response: #{data}"
    
    return data["GetShipmentResponse"]["Shipment"]
  end
  
  def self.pack_list(auth_token, yard_id, pack_shipment_id, pack_contract_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/PackListByShipmentId?shipId=#{pack_shipment_id}&contractId=#{pack_contract_id}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.pack_list response: #{data}"
    
    unless data["MobilePackListInformation"].blank? or data["MobilePackListInformation"]["PackLists"].blank? or data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"].blank?
      return data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"]
    else # No pack found
      return nil
    end
    
#    unless data["MobilePackListInformation"].blank? or data["MobilePackListInformation"]["ContractItems"].blank? or data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"].blank?
#      if data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"].is_a? Hash # Only one result returned, so put it into an array
#        return [data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"]]
#      else # Array of results returned
#        return data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"]
#      end
#    else # No packs found
#      return nil
#    end
  end
  
  def self.contract_items(auth_token, yard_id, pack_shipment_id, pack_contract_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/PackListByShipmentId?shipId=#{pack_shipment_id}&contractId=#{pack_contract_id}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.contract_items response: #{data}"
    
    unless data["MobilePackListInformation"].blank? or data["MobilePackListInformation"]["ContractItems"].blank? or data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"].blank?
      if data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"]]
      else # Array of results returned
        return data["MobilePackListInformation"]["ContractItems"]["ContractItemListInformation"]
      end
    else # No packs found
      return nil
    end
  end
  
  def self.all_by_date_and_customers(auth_token, yard_id, start_date, end_date, customer_ids) # Non-held shipments
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/getshipmentsbycustomer"
    
    payload = {
      "CustomerIds" => customer_ids,
      "StartDate" => "#{start_date} 00:00:00",
      "EndDate" => "#{end_date} 23:59:59"
      }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info json_encoded_payload
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.all_by_date_customers: #{data}"
    
    if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].blank? # No results, so put into empty array
      return []
    else # Array of results returned
      if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash  # Only one result returned, so put it into an array
        return [data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else
        return data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    end
  end
  
  def self.all_by_date(auth_token, yard_id, start_date, end_date) # Non-held shipments
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/getshipmentsbycustomer"
    
    payload = {
      "CustomerIds" => [],
      "StartDate" => "#{start_date} 00:00:00",
      "EndDate" => "#{end_date} 23:59:59"
      }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info json_encoded_payload
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.all_by_date: #{data}"
    
    if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].blank?# No results, so put into empty array
      return []
    else # Array of results returned
      if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash  # Only one result returned, so put it into an array
        return [data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else
        return data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    end
  end
  
  # Get all closed shipments
  def self.all_closed(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/ClosedShipments"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "PackShipment.all_closed response: #{data}"
    
    unless data["GetShipmentsByStatusForMobileResponse"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].blank?
      if data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    else # No shipments found
      return []
    end
  end
  
  # Get given number of closed shipments
  def self.number_of_closed(auth_token, yard_id, number)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/ClosedShipments/#{number}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.number_of_closed response: #{data}"
    
    unless data["GetShipmentsByStatusForMobileResponse"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"].blank? or data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].blank?
      if data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusForMobileResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    else # No shipments found
      return []
    end
  end
  
  def self.all_closed_today(auth_token, yard_id) # Non-held shipments
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/getshipmentsbycustomer"
    
    payload = {
      "CustomerIds" => [],
      "StartDate" => "#{Date.today} 00:00:00",
      "EndDate" => "#{Date.today} 23:59:59"
      }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info json_encoded_payload
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.all_by_date: #{data}"
    
    if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].blank?# No results, so put into empty array
      return []
    else # Array of results returned
      if data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"].is_a? Hash  # Only one result returned, so put it into an array
        return [data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]]
      else
        return data["GetShipmentsByCustomerResponse"]["Shipments"]["ShipmentHeadInformation"]
      end
    end
  end
  
  def self.customer_summary_to_csv(pack_shipments_array)
    require 'csv'
    headers = ['DateShipped', 'ShipmentNumber', 'ContractDescription', 'NetWeight']
    
    CSV.generate(headers: true) do |csv|
      csv << headers

      pack_shipments_array.each do |pack_shipment|
        csv << headers.map{ |attr| pack_shipment[attr] }
      end
    end
  end
  
  def self.commodity_summary_to_csv(pack_lists_array)
    require 'csv'
#    headers = ['DateCreated']
    
    CSV.generate(headers: true) do |csv|
      csv << ['DateCreated', 'InventoryDescription', 'TagNumber', 'NetWeight']

      pack_lists_array.each do |pack_list|
        csv << [pack_list['DateCreated'], pack_list['Items']['PackListItemInformation']['InventoryDescription'], pack_list['Items']['PackListItemInformation']['PackInfo']['TagNumber'], pack_list['Items']['PackListItemInformation']['PackInfo']['NetWeight']]
#        csv << headers.map{ |attr| pack_list[attr] }
      end
    end
  end
  
end