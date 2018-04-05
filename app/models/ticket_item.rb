class TicketItem
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.save_vin(auth_token, yard_id, ticket_item_id, year, make_id, model_id, body_id, color_id, vehicle_id_number)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/savevins"
    payload = {
      "TicketItemsId" => ticket_item_id,
      "VehicleIdentificationNumbers" => [{
          "Id" => SecureRandom.uuid,
          "VehicleIdNumber" => vehicle_id_number,
          "Year" => year,
          "VehicleMakeId" => make_id,
          "VehicleModelId" => model_id,
          "BodyStyleId" => body_id,
          "ColorId" => color_id,
          "TicketItemsId" => ticket_item_id
        }],
      }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.info "payload: #{json_encoded_payload}"
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    return data["SaveVehicleIdentificationNumbersResponse"]
  end
  
  def self.vins(auth_token, yard_id, ticket_item_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/getvins?ticketItemId=#{ticket_item_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    
    unless data["GetVehicleIdentificationNumberListResponse"].blank? or data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"].blank? or data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"].blank?
      if data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"].is_a? Hash
        # Only one VIN for ticket item, so put into array
        return [data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"]]
      else
        # Multiple VIN's for ticket item, so already in an array
        return data["GetVehicleIdentificationNumberListResponse"]["VehicleIdentificationNumbers"]["VehicleIdentificationNumberInformation"]
      end
    else
      return []
    end
  end
  
  # Void/remove a line item from ticket
  def self.void(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/void"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "DateCreated" => Time.now.utc, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "Quantity" => "#{commodity_unit_of_measure == 'EA' ? net : '0'}",
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
#      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Add a line item to a ticket
  def self.quick_add(auth_token, yard_id, item_id, ticket_id, commodity_id, commodity_name, price)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    payload = {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "DateCreated" => Time.now.utc.iso8601, 
          "ExtendedAmount" => 0, 
          "ExtendedAmountInAssignedCurrency" => 0,
          "GrossWeight" => 0,
          "Id" => item_id,
          "NetWeight" => 0,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "Quantity" => "0",
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => 0, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        }
    json_encoded_payload = JSON.generate(payload)
    Rails.logger.debug "******************* TicketItem.quick_add Payload: #{json_encoded_payload}"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
      
    data= Hash.from_xml(response)
    unless data["SaveTicketItemResponse"].blank? or data["SaveTicketItemResponse"]["Success"].blank?
      return data["SaveTicketItemResponse"]["Success"]
    else
      return nil
    end
  end 
  
end