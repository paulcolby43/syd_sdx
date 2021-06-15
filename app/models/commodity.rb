class Commodity
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllByFilterQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($commodity_filter_input: CommodityFilterInput) {
        commodities(where: $commodity_filter_input)
          {
          nodes{
            id
            printDescription
            isDisabled
            scalePrice
            code
            menuText
            multiYardParentItemXlinks{
              parentId
              yard{
                yardName
              }
              item{
                printDescription
              }
            }
            scaleUom{
              description
              code
            }
            commodityTypeUdlvId
            commodityTypeUdlv{
              codeValue
              reportDescription
            }
          }
        }
      }
    GRAPHQL
  
  def self.v2_all_by_filter(filter)
    unless filter.blank?
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {commodity_filter_input: JSON[filter]})
    else
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery)
    end
    unless response.blank? or response.data.blank? or response.data.commodities.blank? or response.data.commodities.nodes.blank?
      return response.data.commodities.nodes
    else
      return []
    end
  end
  
  FindByIdQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($id : Uuid!) {
        commodityById(id : $id){
          ...CommodityModel
        }
      }

      fragment CommodityModel on Commodity {
        id
        printDescription
        menuText
        isDisabled
        scalePrice
        code
        menuText
        multiYardParentItemXlinks{
          parentId
          yard{
            yardName
          }
        }
        scaleUom{
          description
          code
        }
        commodityTypeUdlvId
        commodityTypeUdlv{
          codeValue
          reportDescription
        }
      }
    GRAPHQL
    
  def self.v2_find_by_id(id)
    response = DRAGONQLAPI::Client.query(FindByIdQuery, variables: {id: id})
    unless response.blank? or response.data.blank? or response.data.commodity_by_id.blank?
      return response.data.commodity_by_id
    else
      return nil
    end
  end
  
  ### Getting an error on this, so commenting out for now.
  ### Error: Argument 'input' on Field 'customerCommodityPricing' has an invalid value. Expected type 'CustomerCommodityPricingFilterInput'.
  #PriceByCustomerQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
  #    query($customer_id: Uuid!, $commodity_id: Uuid!, $commodity_net_weight: Decimal){
  #      customerCommodityPricing(input: {
  #        customerId: $customer_id,
  #        commodityId: $commodity_id,
  #        commodityNetWeight: $commodity_net_weight
  #      })
  #      {
  #        price
  #      }
  #    }
  #  GRAPHQL
  #
  #def self.v2_price_by_customer(customer_id, commodity_id, commodity_net_weight)
  #  response = DRAGONQLAPI::Client.query(PriceByCustomerQuery, variables: {customer_id: customer_id, commodity_id: commodity_id, commodity_net_weight: commodity_net_weight})
  #  unless response.blank? or response.data.blank? or response.data.customer_commodity_pricing.blank? or response.data.customer_commodity_pricing.price.blank?
  #    return response.data.customer_commodity_pricing.price
  #  else
  #    return nil
  #  end
  #end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?t=1000"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCommodity9fKlOoru"]["Items"]["ApiCommodity"]
    end
    
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
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data

    data["ApiItemResponseOfApiCommodity9fKlOoru"]["Item"]
  end
  
  def self.search(auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/commodity?q=#{query_string}&t=100&includedisabled=true")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
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
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
#    Rails.logger.info data
    types = data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Items"]["ApiUserDefinedListValue"]
#    Rails.logger.info types
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
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info data
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
    
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info data
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
    
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info data
#    return data
    return data["BaseResponse"]["Success"]
  end
  
  def self.price(auth_token, commodity_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
#    Rails.logger.info data
#    price = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["Price"]
    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
    return response
  end
  
  def self.price_by_customer(auth_token, commodity_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price?customerId=#{customer_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
#    Rails.logger.info data
#    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
    price = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["Price"]
    return price
  end
  
#  def self.taxes_by_customer(auth_token, commodity_id, customer_id)
#    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
#    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price?customerId=#{customer_id}"
#    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
#    data= Hash.from_xml(xml_content)
#    
#    Rails.logger.info "************************taxes_by_customer: #{data}"
##    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]
#    if data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].is_a? Hash 
#      # Only one tax collection result returned
#      unless data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"].blank?
#        return [data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"]]
#      else
#        nil # No tax
#      end
#    else
#      # Multiple taxes
##      return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]
#      return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].map{ |x| x["ApiTax"]}
#    end
#  end
  
  def self.taxes_by_customer(auth_token, commodity_id, customer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/commodity/#{commodity_id}/price?customerId=#{customer_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
#    Rails.logger.info "************************taxes_by_customer: #{data}"
#    response = data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]

    if data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].blank?
      return nil # No tax
    else
      if data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"].is_a? Hash 
        # Only one tax collection result returned
        unless data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"].blank?
          return [data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"]]
        else
          nil # No tax
        end
      else
        # Multiple taxes
#        return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"].map{ |x| x["ApiTax"]}
        return data["ApiItemResponseOfApiCommodityPriceMSmOkoW0"]["Item"]["TaxCollection"]["ApiTax"]
      end
    end
  end
  
  def self.unit_of_measure_weight_conversion(auth_token, to_unit, weight)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/shared/conversion"
    payload = {
      "FromUnit" => 'LB',
      "ToUnit" => to_unit,
      "PreConversionValue" => weight,
      "IsPriceConversion" => false
      }
      
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info "unit_of_measure_conversion call response:#{data}"
#    return data
#    return data["GetConversionFactorResponse"]["ConvertedValue"]
    return data["GetConversionFactorResponse"]
  end
  
  def self.all_by_type_grouped_for_select(types, commodities)
    types.map{|type| Commodity.by_type_grouped_for_select(type, commodities)}
  end
  
  def self.by_type_grouped_for_select(type, commodities)
    [type['ReportDescription'], commodities.select{|c| c['Type'] == type['CodeValue'] }.sort_by {|c| c['PrintDescription']}.collect { |c| [ c['PrintDescription'], c['Id'] ] }]
  end
  
end