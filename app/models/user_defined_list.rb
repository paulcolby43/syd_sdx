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
    DRAGONQLAPI::Client.query(DeductUserDefinedTypeQuery).data.user_defined_lists.nodes.first.user_defined_list_values
  end
  
  def self.deductions_grouped_for_select(deductions)
    deductions.collect{ |d| d.code_value }.sort
  end
  
end