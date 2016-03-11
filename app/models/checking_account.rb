class CheckingAccount
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://71.41.52.58:50002/api/yard/#{yard_id}/checkingaccount"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    Rails.logger.info data
    if data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"].is_a? Hash
      # Put the hash in an array
      return [data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"]]
    else
      return data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"]
    end
  end
  
  
end