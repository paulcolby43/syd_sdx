class Drawer
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id, currency_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/drawer"
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/drawer/getdrawers/currencyId/#{currency_id}"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
#    Rails.logger.info data["ApiItemsResponseOfApiDrawerGJitOhAu"]["Items"]["ApiDrawer"]
    if data["ApiItemsResponseOfApiDrawerGJitOhAu"]["Items"]["ApiDrawer"].is_a? Hash
      # Put the hash in an array
      return [data["ApiItemsResponseOfApiDrawerGJitOhAu"]["Items"]["ApiDrawer"]]
    else
      return data["ApiItemsResponseOfApiDrawerGJitOhAu"]["Items"]["ApiDrawer"]
    end
  end
  
  def self.status(auth_token, yard_id, drawer_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "#{user.company.dragon_api}/api/yard/#{yard_id}/drawer/#{drawer_id}/status"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    data["ApiItemResponseOfDrawerStatusTypeb_S917hz8"]["Item"]
  end
  
end