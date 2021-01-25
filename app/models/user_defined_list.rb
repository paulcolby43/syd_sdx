class UserDefinedList
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        userDefinedLists
          {
          nodes{
            id,
            userDefinedType,
            userDefinedListValues {
              id,
              codeValue,
              reportDescription
            }
          }
        }
      }
    GRAPHQL
    
  def self.v2_find_all
    DRAGONQLAPI::Client.query(FindAllQuery)
  end
  
  FindByIdQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($id : Uuid!) {
        userDefinedListValueById(id : $id){
          ...UserDefinedListValueModel
        }
      }

      fragment UserDefinedListValueModel on UserDefinedListValue {
        id
        codeValue
        reportDescription
        listId
        }
    GRAPHQL
    
  def self.v2_find_by_id(id)
    response = DRAGONQLAPI::Client.query(FindByIdQuery, variables: {id: id})
    unless response.blank? or response.data.blank? or response.data.user_defined_list_value_by_id.blank?
      return response.data.user_defined_list_value_by_id
    else
      return nil
    end
  end
  
  DeductUserDefinedTypeQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        userDefinedLists(where: {userDefinedType: {eq: DEDUCT_REASON}})
          {
          nodes{
            userDefinedListValues {
              id,
              codeValue,
              reportDescription
            }
          }
        }
      }
    GRAPHQL
  
  def self.v2_deduct_reasons
    response = DRAGONQLAPI::Client.query(DeductUserDefinedTypeQuery)
    unless response.blank? or response.data.blank? or response.data.user_defined_lists.blank? or response.data.user_defined_lists.nodes.blank? or response.data.user_defined_lists.nodes.first.blank? or response.data.user_defined_lists.nodes.first.user_defined_list_values.blank?
      return response.data.user_defined_lists.nodes.first.user_defined_list_values
    else
      return []
    end
  end
  
  def self.deductions_grouped_for_select(deductions)
    deductions.collect{ |d| d.code_value }.sort
  end
  
  FerrousNonFerrousUserDefinedTypeQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query {
        userDefinedLists(where: {userDefinedType: {eq: FERROUS_OR_NONFERROUS}})
          {
          nodes{
            userDefinedListValues {
              id,
              codeValue,
              reportDescription
            }
          }
        }
      }
    GRAPHQL
  
  def self.v2_commodity_types
    response = DRAGONQLAPI::Client.query(FerrousNonFerrousUserDefinedTypeQuery)
    unless response.blank? or response.data.blank? or response.data.user_defined_lists.blank? or response.data.user_defined_lists.nodes.blank? or response.data.user_defined_lists.nodes.first.blank? or response.data.user_defined_lists.nodes.first.user_defined_list_values.blank?
      return response.data.user_defined_lists.nodes.first.user_defined_list_values
    else
      return []
    end
  end
  
end