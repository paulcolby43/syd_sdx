class Commodity
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?t=100"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
  end
  
#  def self.all_disabled(auth_token, yard_id)
#    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
#    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?t=100&includedisabled=true"
#    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
#    data= Hash.from_xml(xml_content)
#    
#    data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
#  end
  
#  def self.find_by_id(auth_token, yard_id, commodity_id)
#    commodities = Commodity.all(auth_token, yard_id)
#    commodities.find {|commodity| commodity['Id'] == commodity_id}
#  end
  
  def self.find_by_id(auth_token, yard_id, commodity_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity/#{commodity_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data

    data["ApiItemResponseOfApiCommodity9fKlOoru"]["Item"]
  end
  
  def self.search(auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?q=#{query_string}&t=100&includedisabled=true")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
    end
  end
  
#  def self.search_disabled(auth_token, yard_id, query_string)
#    require 'uri'
#    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
#    user = access_token.user # Get access token's user record
#    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?q=#{query_string}&t=100&includedisabled=true")
#    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
#    data= Hash.from_xml(xml_content)
#    
#    if data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"].is_a? Hash # Only one result returned, so put it into an array
#      return [data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]]
#    else # Array of results returned
#      return data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
#    end
#  end
  
  def self.types(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/udl/9"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
#    Rails.logger.info data
    types = data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Items"]["ApiUserDefinedListValue"]
    Rails.logger.info types
    types
  end
  
  def self.create(auth_token, yard_id, commodity_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity"
    new_guid = SecureRandom.uuid
    payload = {
      "Id" => new_guid,
      "Code" => commodity_params[:description],
      "Name" => commodity_params[:description],
      "PrintDescription" => commodity_params[:description],
      "YardId" => yard_id,
      "YardName" => commodity_params[:yard_name],
      "ScalePrice" => commodity_params[:scale_price],
      "UnitOfMeasure" => commodity_params[:unit_of_measure],
      "MaxPrice" => 0.0,
      "MaxUnit" => "",
      "Type" => commodity_params[:type],
      "Shrink" => 0.0,
      "IsDisabled" => false,
      "ForegroundColor" => "#000000",
      "BackgroundColor" => "#ffffff",
      "TextSize" => 16,
      "IsParentItem" => true,
      "ParentId" => nil,
      "MenuText" => commodity_params[:description],
      "IsTaxable" => true
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data
    return data["BaseResponse"]["Success"]
  end
  
  def self.update(auth_token, yard_id, commodity_params)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity"
    payload = {
      "Id" => commodity_params[:id],
      "Code" => commodity_params[:code],
      "Name" => commodity_params[:name],
      "PrintDescription" => commodity_params[:description],
      "YardId" => yard_id,
      "YardName" => commodity_params[:yard_name],
      "ScalePrice" => commodity_params[:scale_price],
      "UnitOfMeasure" => commodity_params[:unit_of_measure],
      "MaxPrice" => 0.0,
      "MaxUnit" => "",
      "Type" => commodity_params[:type],
      "Shrink" => 0.0,
#      "IsDisabled" => false,
      "IsDisabled" => "#{(commodity_params[:is_disabled] == '1') ? true : false}",
      "ForegroundColor" => "#000000",
      "BackgroundColor" => "#ffffff",
      "TextSize" => 16,
      "IsParentItem" => true,
      "ParentId" => commodity_params[:parent_id],
      "MenuText" => commodity_params[:menu_text],
      "IsTaxable" => true
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data
    return data["BaseResponse"]["Success"]
  end
  
  def self.update_price(auth_token, yard_id, commodity_id, new_price)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    payload = {
      "Id" => commodity['Id'],
      "Code" => commodity['Code'],
      "Name" => commodity['Name'],
      "PrintDescription" => commodity['PrintDescription'],
      "YardId" => commodity['YardId'],
      "YardName" => commodity['YardName'],
      "ScalePrice" => new_price,
      "UnitOfMeasure" => commodity['UnitOfMeasure'],
      "MaxPrice" => 0.0,
      "MaxUnit" => "",
      "Type" => commodity['Type'],
      "Shrink" => 0.0,
      "IsDisabled" => false,
      "ForegroundColor" => "#000000",
      "BackgroundColor" => "#ffffff",
      "TextSize" => 16,
      "IsParentItem" => true,
      "ParentId" => commodity['ParentId'],
      "MenuText" => commodity['MenuText'],
      "IsTaxable" => true
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    Rails.logger.info data
#    return data
    return data["BaseResponse"]["Success"]
  end
  
  def self.price(auth_token, commodity_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    Rails.logger.info data
#    price = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["Price"]
    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
    return response
  end
  
  def self.price_by_customer(auth_token, commodity_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price?customerId=#{customer_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    Rails.logger.info data
#    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
    price = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["Price"]
    return price
  end
  
  def self.taxes_by_customer(auth_token, commodity_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price?customerId=#{customer_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    Rails.logger.info data
#    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
    if data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].is_a? Hash # Only one tax collection result returned
      unless data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"].blank?
        return [data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"]]
      else
        nil # No tax
      end
    else
      # Multiple taxes
#      return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]
      return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].map{ |x| x["ApiTax"]}
    end
  end
  
end