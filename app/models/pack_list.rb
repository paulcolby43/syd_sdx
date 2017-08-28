class PackList
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # Get all packs_lists by contract ID
  def self.all(auth_token, yard_id, contract_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/PackLists"
    
    payload = {
      "ContractId" => contract_id
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json'}, :payload => json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.info "Pack Lists response: #{data}"
    
    unless data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"].blank?
      if data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"].is_a? Hash # Only one result returned, so put it into an array
        return [data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"]]
      else # Array of results returned
        return data["MobilePackListInformation"]["PackLists"]["PackListHeadInformation"]
      end
    else # No pack lists found
      return []
    end
  end
  
  def self.find(auth_token, yard_id, pack_list_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/PackList?packlistId=#{pack_list_id}"
    
    payload = {
      "Id" => pack_list_id
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, :payload => json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackList.find response: #{data}"
    
    unless data["GetPackingListResponse"].blank? or data["GetPackingListResponse"]["PackList"].blank?
      return data["GetPackingListResponse"]["PackList"]
    else # No pack list found
      return nil
    end
  end
  
  def self.find_by_id(auth_token, yard_id, contract_id, pack_list_id)
    pack_lists = PackList.all(auth_token, yard_id, contract_id)
    # Find pack list within array of hashes
    pack_list = pack_lists.find {|pl| pl['Id'] == pack_list_id}
    return pack_list
  end
  
  def self.update(auth_token, yard_id, pack_list_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/PackList"
    payload = {
      "Id" => pack_list_params[:id],
      "PrintDescription" => pack_list_params[:description],
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data
    return data["SavePackResponse"]["Success"]
  end
  
  def self.pack_items(auth_token, yard_id, pack_list_id)
    pack_list = PackList.find(auth_token, yard_id, pack_list_id)
    
    unless pack_list.blank? or pack_list['Items'].blank?
      unless pack_list['Items']['PackListItemInformation'].is_a? Hash
      # Multiple material items
        pack_items = pack_list['Items']['PackListItemInformation']
      else
        # One material item
        pack_items = [pack_list['Items']['PackListItemInformation']]
      end
      return pack_items
    else
      return []
    end
  end
  
  def self.add_pack(auth_token, yard_id, pack_list_id, pack_id)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/AddPackToPackingList"
    
    payload = {
      "PackListId" => pack_list_id,
      "PackId" => pack_id,
      #"InternalPackNumber" => internal_pack_number,
      #"TagNumber" => tag_number,
      "AddNewContractItem" => false
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    Rails.logger.info "Add Pack json_encoded_payload: #{json_encoded_payload}"
    
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackList.add_pack response: #{data}"
    
    return data["AddPackToPackingListResponse"]
  end
  
  def self.remove_pack(auth_token, yard_id, pack_list_id, pack_id)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/RemovePackFromPackList?packlistId=#{pack_list_id}&packId=#{pack_id}"
    
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"})
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackList.remove_pack response: #{data}"
    
    return data["RemovePackFromPackListResponse"]
  end
  
  def self.add_pack_to_contract_item(auth_token, yard_id, pack_list_id, pack_id, contract_item_id)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/shipping/AddPackToContractItem"
    
    payload = {
      "PackListId" => pack_list_id,
      "PackId" => pack_id,
      "ContractItemId" => contract_item_id
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    Rails.logger.info "Add pack to contract item json_encoded_payload: #{json_encoded_payload}"
    
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
    Rails.logger.info "PackList.add_pack_to_contract_item response: #{data}"
    
    return data["AddPackToContractItemResponse"]
  end
  
end