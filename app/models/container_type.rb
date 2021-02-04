class ContainerType
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllByFilterQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
    query($dispatch_container_type_filter_input: DispatchContainerTypeFilterInput) {
      dispatchContainerTypes(where: $dispatch_container_type_filter_input)
        {
        nodes{
            id
            description
            type
          }
        }
      }
    GRAPHQL
    
  def self.v2_all_by_filter(filter)
    unless filter.blank?
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {dispatch_container_type_filter_input: JSON[filter]})
    else
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery)
    end
    unless response.blank? or response.data.blank? or response.data.dispatch_container_types.blank? or response.data.dispatch_container_types.nodes.blank?
      return response.data.dispatch_container_types.nodes
    else
      return []
    end
  end
  
end