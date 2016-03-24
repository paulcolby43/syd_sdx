class Customer
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer?t=100"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id, customer_id)
    customers = Customer.all(auth_token, yard_id)
    customers.find {|customer| customer['Id'] == customer_id}
  end
  
  def self.search(auth_token, yard_id, query_string)
    require 'uri'
    api_url = URI.encode("https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer?q=#{query_string}&t=100")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
  def self.create(auth_token, yard_id, customer_params)
    require 'json'
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer"
    new_guid = SecureRandom.uuid
    payload = {
      "Address1"=> customer_params[:address_1], 
      "Address2"=> customer_params[:address_2], 
      "BuyTaxCode"=>nil, 
      "CheckAddress1"=>"", 
      "CheckAddress2"=>"", 
      "CheckCity"=>"", 
      "CheckName"=>"", 
      "CheckPayTo"=>"", 
      "CheckState"=>"", 
      "CheckZip"=>"", 
      "City"=> customer_params[:city], 
      "Company"=> customer_params[:company], 
      "Country"=>"", 
      "CurrencyId"=>"00000000-0000-0000-0000-000000000000", 
      "CustomerNumber"=>"", 
      "Extension"=>"", 
      "FirstName"=> customer_params[:first_name], 
      "Id"=>new_guid, 
      "IdExpires"=>nil, 
      "IdNumber"=>"", 
      "IdState"=>"", 
      "IsDisabled"=>"false", 
      "LastName"=> customer_params[:last_name], 
      "MiddleName"=>"", 
      "PayToCompany"=>nil, 
      "PayToFirstName"=>nil, 
      "PayToId"=>"48ea7fec-9283-4da5-b2f2-9900d3133fac", 
      "PayToLastName"=>nil, 
      "Phone"=> customer_params[:phone], 
      "SellTaxCode"=>nil, 
      "State"=> customer_params[:state], 
      "TaxCollection"=> [
          {
            "CustomerId"=>new_guid, 
            "Id"=>SecureRandom.uuid, 
            "IsBuySide"=>"true", 
            "IsTaxEligible"=>"false", 
            "OverrideTaxRate"=>"0", 
            "SalesTaxId"=>"08bde472-dea4-48a5-92c4-15429307bba8", 
            "TaxName"=>"PST", "TaxPercent"=>"8.00"
          }
        ], 
      "Zip"=> customer_params[:zip]
      }
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
    return data["ApiItemResponseOfApiCustomerC9S9lUui"]["Success"]
  end
  
  def self.update(auth_token, yard_id, customer_params)
    require 'json'
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer"
    payload = {
      "Address1"=> customer_params[:address_1], 
      "Address2"=> customer_params[:address_2], 
      "BuyTaxCode"=>nil, 
      "CheckAddress1"=>"", 
      "CheckAddress2"=>"", 
      "CheckCity"=>"", 
      "CheckName"=>"", 
      "CheckPayTo"=>"", 
      "CheckState"=>"", 
      "CheckZip"=>"", 
      "City"=> customer_params[:city], 
      "Company"=> customer_params[:company], 
      "Country"=>"", 
      "CurrencyId"=>"00000000-0000-0000-0000-000000000000", 
      "CustomerNumber"=>"", 
      "Extension"=>"", 
      "FirstName"=> customer_params[:first_name], 
      "Id"=> customer_params[:id], 
      "IdExpires"=>nil, 
      "IdNumber"=>"", 
      "IdState"=>"", 
      "IsDisabled"=>"false", 
      "LastName"=> customer_params[:last_name], 
      "MiddleName"=>"", 
      "PayToCompany"=>nil, 
      "PayToFirstName"=>nil, 
      "PayToId"=>"48ea7fec-9283-4da5-b2f2-9900d3133fac", 
      "PayToLastName"=>nil, 
      "Phone"=> customer_params[:phone], 
      "SellTaxCode"=>nil, 
      "State"=> customer_params[:state], 
      "TaxCollection"=> customer_params[:tax_collection], 
      "Zip"=> customer_params[:zip]
      }
    json_encoded_payload = JSON.generate(payload)
    
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json'},
      payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info data
    return data["ApiItemResponseOfApiCustomerC9S9lUui"]["Success"]
  end
  
end