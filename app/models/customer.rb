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
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer?q=#{query_string}&t=100"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
  def self.create(auth_token, yard_id)
    require 'json'
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/customer"
    new_guid = SecureRandom.uuid
    
    payload = {
      "Customer"  => {
        "Address1"=>nil, 
        "Address2"=>nil, 
        "BuyTaxCode"=>{"i:nil"=>"true"}, 
        "CheckAddress1"=>nil, 
        "CheckAddress2"=>nil, 
        "CheckCity"=>nil, 
        "CheckName"=>" ", 
        "CheckPayTo"=>" ", 
        "CheckState"=>nil, 
        "CheckZip"=>nil, "City"=>nil, 
        "Company"=>nil, "Country"=>nil, 
        "CurrencyId"=>"00000000-0000-0000-0000-000000000000", 
        "CustomerNumber"=>"", 
        "Extension"=>nil, 
        "FirstName"=>nil, 
        "Id"=>new_guid, 
        "IdExpires"=>{"i:nil"=>"true"}, 
        "IdNumber"=>nil, 
        "IdState"=>nil, 
        "IsDisabled"=>"false", 
        "LastName"=>nil, 
        "MiddleName"=>nil, 
        "PayToCompany"=>{"i:nil"=>"true"}, 
        "PayToFirstName"=>{"i:nil"=>"true"}, 
        "PayToId"=>"48ea7fec-9283-4da5-b2f2-9900d3133fac", 
        "PayToLastName"=>{"i:nil"=>"true"}, 
        "Phone"=>nil, 
        "SellTaxCode"=>{"i:nil"=>"true"}, 
        "State"=>nil, 
        "TaxCollection"=> {
          "ApiCustomerSalesTax"=> [{
              "CustomerId"=>new_guid, 
              "Id"=>SecureRandom.uuid, 
              "IsBuySide"=>"true", 
              "IsTaxEligible"=>"false", 
              "OverrideTaxRate"=>"0", 
              "SalesTaxId"=>"08bde472-dea4-48a5-92c4-15429307bba8", 
              "TaxName"=>"PST", "TaxPercent"=>"8.00"}
            ]}, 
          "Zip"=>nil
        }
      }
    json_encoded_payload = JSON.generate(payload)
    
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiCustomerC9S9lUui"]["Items"]["ApiCustomer"]
    end
  end
  
end