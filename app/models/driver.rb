class Driver
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllByFilterQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($driver_filter_input: DriverFilterInput) {
        drivers(where: $driver_filter_input)
          {
          nodes{
              id
              firstName
              lastName
            }
          }
        }
    GRAPHQL
  
  def self.v2_all_by_filter(filter)
    unless filter.blank?
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {driver_filter_input: JSON[filter]})
    else
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery)
    end
    unless response.blank? or response.data.blank? or response.data.drivers.blank? or response.data.drivers.nodes.blank?
      return response.data.drivers.nodes
    else
      return []
    end
  end
  
end