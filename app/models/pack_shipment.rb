class PackShipment
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # Get all packs_shipments
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/HeldShipments"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackShipment.all response: #{data}"
    
    unless data["GetShipmentsByStatusResponse"].blank? or data["GetShipmentsByStatusResponse"]["Shipments"].blank? or data["GetShipmentsByStatusResponse"]["Shipments"]["ShipmentListInformation"].blank?
      if data["GetShipmentsByStatusResponse"]["Shipments"]["ShipmentListInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["GetShipmentsByStatusResponse"]["Shipments"]["ShipmentListInformation"]]
      else # Array of results returned
        return data["GetShipmentsByStatusResponse"]["Shipments"]["ShipmentListInformation"]
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
  
end