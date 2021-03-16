#class Contract < ActiveRecord::Base
class Contract

#  establish_connection :jpegger
#  self.table_name = 'contracts'
#  self.primary_key = 'contract_id'
#  belongs_to :company

  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        contractHeads
          {
          nodes{
            id
            contractNumber
            contractDescription
            contractStatus
            yardId
          }
        }
      }
    GRAPHQL
  
  def self.v2_find_all
    response = DRAGONQLAPI::Client.query(FindAllQuery)
    unless response.blank? or response.data.blank? or response.data.contract_heads.blank? or response.data.contract_heads.nodes.blank?
      response.data.contract_heads.nodes 
    else
      nil
    end
  end
  
  FindAllByFilterQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($contract_head_filter_input: ContractHeadFilterInput) {
        contractHeads(where: $contract_head_filter_input)
          {
          nodes{
            id
            contractNumber
            contractDescription
            contractStatus
            yardId
          }
        }
      }
    GRAPHQL
  
  def self.v2_all_by_filter(filter)
    Rails.logger.debug "*************#{filter}"
    unless filter.blank?
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {contract_head_filter_input: JSON[filter]})
    else
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery)
    end
    unless response.blank? or response.data.blank? or response.data.contract_heads.blank? or response.data.contract_heads.nodes.blank?
      response.data.contract_heads.nodes 
    else
      []
    end
  end
  
  FindByIdQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($id : Uuid!) {
        contractHeadById(id : $id){
          ...ContractHeadModel
        }
      }

      fragment ContractHeadModel on ContractHead {
        id
        contractNumber
        contractDescription
        contractStatus
        yardId
        }
    GRAPHQL
  
  def self.v2_find_by_id(id)
    response = DRAGONQLAPI::Client.query(FindByIdQuery, variables: {id: id})
    unless response.blank? or response.data.blank? or response.data.contract_head_by_id.blank?
      return response.data.contract_head_by_id 
    else
      return nil
    end
  end
  
  #############################
  #     Instance Methods      #
  ############################
  
#  def company
#    Company.find_by_CompanyID(contract_id)
#  end
  
#  def verbiage
#    "#{text1} #{text2} #{text3} #{text4}"
#  end
  
  #############################
  #     Class Methods      #
  #############################

end

