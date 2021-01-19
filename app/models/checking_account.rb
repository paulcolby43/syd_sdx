class CheckingAccount
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        checkAccounts
          {
          nodes{
            id
            name
          }
        }
      }
    GRAPHQL
  
  def self.v2_find_all
    response = DRAGONQLAPI::Client.query(FindAllQuery)
    unless response.blank? or response.data.blank? or response.data.check_accounts.blank? or response.data.check_accounts.nodes.blank?
      response.data.check_accounts.nodes 
    else
      nil
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/checkingaccount"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
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