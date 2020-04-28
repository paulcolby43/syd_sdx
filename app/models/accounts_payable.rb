class AccountsPayable
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  # Get all accounts payable by ticket ID
  def self.all(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    Rails.logger.debug "*********AccountPayable.all: #{data}"
    unless data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"].blank? or data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"].blank? or data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"].blank?
      if data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]]
      else # Array of results returned
        # This will only be more than one if this is a preexisting ticket that had a payment split or payment was split by the device.
        return data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]
      end
    else
      return []
    end
  end
  
  def self.find_by_id(auth_token, yard_id, ticket_id, accounts_payable_id)
    accounts_payables = AccountsPayable.all(auth_token, yard_id, ticket_id)
#    Rails.logger.info accounts_payables
    accounts_payables.find {|accounts_payable| accounts_payable['Id'] == accounts_payable_id}
  end
  
  def self.update(auth_token, yard_id, ticket_id, accounts_payable_item)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem"
#    new_accounts_payable_item = accounts_payable_item
#    new_accounts_payable_item["AmountDue"] = "9"
#    new_accounts_payable_item["AmountDueInAssignedCurrency"] = "9"
#    new_accounts_payable_item["Id"] = SecureRandom.uuid
#    accounts_payable_item["AmountDue"] = "20"
#    accounts_payable_item["AmountDueInAssignedCurrency"] = "20"
    
    payload = [accounts_payable_item]
#      {
#      "AmountDue"=>"20.00", 
#      "AmountDueInAssignedCurrency"=>"20.00", 
#      "CashierId"=>{"i:nil"=>"true"}, 
#      "CheckNumber"=>{"i:nil"=>"true"}, 
#      "Company"=>{"i:nil"=>"true"}, 
#      "CreatedDate"=>"2016-07-12T13:50:33.913", 
#      "CurrencyCode"=>"USD ", 
#      "CurrencyId"=>"24ea72a0-3650-431e-87e6-35ca5bd6dab5", 
#      "CustomerName"=>{"i:nil"=>"true"}, 
#      "CustomerNumber"=>{"i:nil"=>"true"}, 
#      "DueDate"=>"2016-07-12T13:50:33.863", 
#      "Id"=>"86d2ff78-d523-4a1b-9f17-4946a0a8791d", 
#      "MailRequired"=>"false", 
#      "PaidAmount"=>"0", 
#      "PaidAmountInAssignedCurrency"=>"0", 
#      "PaidByUserId"=>nil, 
#      "PaidDate"=>{"i:nil"=>"true"}, 
#      "PayAfterDate"=>{"i:nil"=>"true"}, 
#      "PayToAddr1"=>nil, 
#      "PayToAddr2"=>nil, 
#      "PayToCity"=>nil, 
#      "PayToCompany"=>nil, 
#      "PayToFirstName"=>"test5", 
#      "PayToId"=>"0c2693ff-11f4-484b-ae29-f5d0813c5d42", 
#      "PayToLastName"=>nil, "PayToName"=>"test5 ", 
#      "PayToState"=>nil, 
#      "PayToZip"=>nil, 
#      "PaymentMethod"=>"1", 
#      "PaymentStatus"=>"0", 
#      "ReceiptNumber"=>{"i:nil"=>"true"}, 
#      "RequirePayMethod"=>"0", 
#      "TicketHeadId"=>"01f3d899-b7ed-437f-bb11-e19e6c437eaf", 
#      "TicketNumber"=>"0", 
#      "UserId"=>"00000000-0000-0000-0000-000000000000", 
#      "VoidCashierId"=>{"i:nil"=>"true"}, 
#      "VoidDate"=>{"i:nil"=>"true"}, 
#      "VoidedByUserId"=>{"i:nil"=>"true"}, 
#      "YardId"=>"1612c2ea-4891-4f5a-84f6-b8c5f73ceb7c"
#      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :put, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
    payload: json_encoded_payload)
    data= Hash.from_xml(response)
#    Rails.logger.info "*******************Accounts Payable Items Update: #{data}**************"
  end
  
end