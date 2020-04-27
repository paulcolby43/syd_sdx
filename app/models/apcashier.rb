class Apcashier
  
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
    if data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]]
    else # Array of results returned
      # This will only be more than one if this is a preexisting ticket that had a payment split or payment was split by the device.
      return data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id, cashier_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/apcashier/#{cashier_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data = Hash.from_xml(xml_content)
#    Rails.logger.info data
    return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]["Item"]["AccountesPayableLineItemCollection"]["ApiAccountsPayableLineItem"]
  end
  
end