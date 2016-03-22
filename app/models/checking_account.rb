class CheckingAccount
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    api_url = "https://#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}/api/yard/#{yard_id}/checkingaccount"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
    data= Hash.from_xml(xml_content)
    if data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"].is_a? Hash
      # Put the hash in an array
      return [data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"]]
    else
      return data["ApiItemsResponseOfApiCheckAccountEmq_PyO3s"]["Items"]["ApiCheckAccount"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id, checking_account_id)
    checking_accounts = CheckingAccount.all(auth_token, yard_id)
#    Rails.logger.info checking_accounts
    checking_accounts.find {|checking_account| checking_account['Id'] == checking_account_id}
  end
  
end