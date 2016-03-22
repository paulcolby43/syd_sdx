class Drawer
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/drawer"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
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
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/drawer/#{drawer_id}/status"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    data["ApiItemResponseOfDrawerStatusTypeb_S917hz8"]["Item"]
  end
  
end