class Yard
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAll = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        yards
          {
          nodes{
            id
            name
          }
        }
      }
    GRAPHQL
    
  def self.v2_all
    response = DRAGONQLAPI::Client.query(FindAll)
    unless response.blank? or response.data.blank? or response.data.yards.blank? or response.data.yards.nodes.blank?
      return response.data.yards.nodes
    else
      return []
    end
  end
  
  FindByIdQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($id : Uuid!) {
        yardById(id : $id){
          ...YardModel
        }
      }

      fragment YardModel on Yard {
        id
        name
      }
    GRAPHQL
  
  def self.v2_find_by_id(id)
    response = DRAGONQLAPI::Client.query(FindByIdQuery, variables: {id: id})
    unless response.blank? or response.data.blank? or response.data.yard_by_id.blank?
      return response.data.yard_by_id 
    else
      return nil
    end
  end
  
  ############################
  #     Instance Methods     #
  ############################
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user/yard"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
#    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"]
    if data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"].is_a? Hash # Only one yard returned, so put it into an array
      return [data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"]]
    else # Array of yards returned
      return data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id)
#    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
#    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/user/yard"
#    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}"})
#    data= Hash.from_xml(xml_content)

#    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"].find {|yard| yard['Id'] == yard_id}
    
    yards = Yard.all(auth_token)
    yards.find {|yard| yard['Id'] == yard_id}
  end
  
  def self.find_by_name(auth_token, yard_name)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/user/yard"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiYard43XWZGCj"]["Items"]["ApiYard"].find {|yard| yard['Name'] == yard_name}
  end
  
  def self.contract(yard_id)
    Contract.where(contract_id: yard_id).last
  end
  
  def self.device_groups(yard_id)
    if Yard.device_groups_table_exists?
      DeviceGroup.where(CompanyID: yard_id)
    end
  end
  
  def self.device_groups_table_exists?
    DeviceGroup.connection
    rescue TinyTds::Error
      false
    else
      true
  end
end