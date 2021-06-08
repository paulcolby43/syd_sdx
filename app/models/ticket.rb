class Ticket
  
  #############################
  # V2 - GraphQL Class Methods#
  #############################
  
  FindAllByFilterQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query($ticket_head_filter_input: TicketHeadFilterInput) {
        ticketHeads(order: {dateCreated: DESC}
        where: $ticket_head_filter_input first: 500)
          {
          totalCount
          nodes {
            id
            ticketNumber
            ticketStatus
            description
            dateCreated
            customerId
            yardId
            customer{
              ...CustomerModel
            },
            ticketItems {
              id
              ticketHead {
                ticketNumber
                ticketStatus
                customer{
                  ...CustomerModel
                }
              }
              dateCreated
              printDescription
              price
              priceUnitOfMeasure
              scaleUnitOfMeasure
              extendedAmount
              ticketHeadId
              ticketItemStatus
              grossWeight
              tareWeight
              netWeight
              ticketItemTaxes{
                taxAmount
              }
              ticketItemDeductions {
                id
                deductWeight
                deductWeightDescription
                deductDollarAmount
                deductDollarAmountDescription
              }
            }
            accountPayableLineItems  {
              amountDue
              amountDueInAssignedCurrency
              paidAmount
              paymentStatus
              paymentMethod
              cashier{
                paymentMethod
                accountsPayableChecks{
                  checkNumber
                }
              }
            }
          }
        }
      }
      fragment CustomerModel on Customer {
        id
        firstName
        lastName
        company
      }
    GRAPHQL
    
  def self.v2_all_by_filter(filter)
    unless filter.blank?
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {ticket_head_filter_input: JSON[filter]})
    else
      response = DRAGONQLAPI::Client.query(FindAllByFilterQuery)
    end
    unless response.blank? or response.data.blank? or response.data.ticket_heads.blank? or response.data.ticket_heads.nodes.blank?
      return response.data.ticket_heads.nodes
    else
      return []
    end
  end
  
  FindByIdQuery = DRAGONQLAPI::Client.parse <<-'GRAPHQL'
      query ($id : Uuid!) {
        ticketHeadById(id : $id){
            ...TicketHeadModel
          }
        }
      fragment TicketHeadModel on TicketHead{
        id
        ticketNumber
        ticketStatus
        description
        dateCreated
        customerId
        yardId
        customer{
          ...CustomerModel
        }
        ticketItems {
          id
          dateCreated
          commodityId
          printDescription
          quantity
          grossWeight
          tareWeight
          netWeight
          price
          priceUnitOfMeasure
          scaleUnitOfMeasure
          extendedAmount
          ticketItemStatus
          serialNumber
          notes
          ticketItemTaxes{
            taxAmount
            taxPercent
          }
          ticketItemDeductions {
            id
            deductWeight
            deductWeightDescription
            deductDollarAmount
            deductDollarAmountDescription
          }
        }
        accountPayableLineItems  {
          amountDue
          amountDueInAssignedCurrency
          paidAmount
          paymentMethod
          cashier{
            paymentMethod
            accountsPayableChecks{
              checkNumber
            }
          }
        }
      }
      fragment CustomerModel on Customer {
        id
        firstName
        lastName
        company
      }
    GRAPHQL
    
  def self.v2_find_by_id(id)
    response = DRAGONQLAPI::Client.query(FindByIdQuery, variables: {id: id})
    unless response.blank? or response.data.blank? or response.data.ticket_head_by_id.blank?
      return response.data.ticket_head_by_id 
    else
      return nil
    end
  end
  
  def self.v2_line_items_total(ticket_items)
    total = 0
    ticket_items.each do |ticket_item|
      total = total + ticket_item.extended_amount.to_d
      # Add in any taxes
      ticket_item.ticket_item_taxes.each do |ticket_item_tax|
        total = total + ticket_item_tax.tax_amount.to_d
      end
    end
    return total
  end
  
  def self.v2_all_paid_by_customer_id(customer_id)
    filter = ' {"ticketStatus": {"eq": "PAID"}, "customerId": {"eq": "' + customer_id + '"}} '
    response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {ticket_head_filter_input: JSON[filter]})
    unless response.blank? or response.data.blank? or response.data.ticket_heads.blank? or response.data.ticket_heads.nodes.blank?
      return response.data.ticket_heads.nodes
    else
      return nil
    end
  end
  
  def self.v2_all_closed_by_customer_id(customer_id)
    filter = ' {"ticketStatus": {"eq": "CLOSED"}, "customerId": {"eq": "' + customer_id + '"}} '
    response = DRAGONQLAPI::Client.query(FindAllByFilterQuery, variables: {ticket_head_filter_input: JSON[filter]})
    unless response.blank? or response.data.blank? or response.data.ticket_heads.blank? or response.data.ticket_heads.nodes.blank?
      return response.data.ticket_heads.nodes
    else
      return nil
    end
  end
  
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.all_by_status_and_yard(status, auth_token, yard_id)
#    status = 'held' if status == 'Hold'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/bydays?d=60"
    payload = {
      "CustomerIds" => [],
      "Take" => 200, 
#      "PaymentType" => [status],
      "TicketStatuses" => [status],
      "ShowAllYards" => false # Only get this yard's tickets
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info "payload: #{json_encoded_payload}"
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Ticket.all_by_status_and_yard response: #{data}"
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.all_today(status, auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=1&t=100"
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=0&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
      
  end
  
  def self.all_last_30_days(status, auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=30&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
  def self.all_last_90_days(status, auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=90&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
  def self.all_last_365_days(status, auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?d=365&t=100"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    unless data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"].blank? or data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].blank?
      if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
        return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
      else # Array of results returned
        return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
      end
    else
      return []
    end
  end
  
  def self.all_by_date_and_status(status, auth_token, yard_id, start_date, end_date)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}/bydate?startdate=#{start_date}T00:00:00&enddate=#{end_date}T23:59:59&t=200"
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/bydate"
    payload = {
      "CustomerIds" => [],
      "StartDate" => start_date,
      "EndDate" => end_date,
      "Take" => 1000, 
      "PaymentType" => [status],
      "ShowAllYards" => true # Pass back tickets from all yards
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.all_by_date_and_status_and_yard(status, auth_token, yard_id, start_date, end_date)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}/bydate?startdate=#{start_date}T00:00:00&enddate=#{end_date}T23:59:59&t=200"
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/bydate"
    payload = {
      "CustomerIds" => [],
      "StartDate" => start_date,
      "EndDate" => end_date,
      "Take" => 1000, 
      "TicketStatuses" => [status].flatten, # Need to flatten in case we're getting an array of statuses passed, since we don't want to pass Dragon an array of an array
      "ShowAllYards" => false # Only tickets from this yard
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.debug "payload: #{json_encoded_payload}"
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
    Rails.logger.debug "****************************data: #{data}"
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.all_by_date_and_yard(auth_token, yard_id, start_date, end_date)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}/bydate?startdate=#{start_date}T00:00:00&enddate=#{end_date}T23:59:59&t=200"
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/bydate"
    payload = {
      "CustomerIds" => [],
      "StartDate" => start_date,
      "EndDate" => end_date,
      "Take" => 1000, 
      "TicketStatuses" => [1,2,3], # All statuses
      "ShowAllYards" => false # Only tickets from this yard
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
        :content_type => 'application/json', :Accept => "application/xml"}, payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.all_by_date_and_customers(status, auth_token, yard_id, start_date, end_date, customer_ids)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/bydate"
    
    payload = {
      "CustomerIds" => customer_ids,
      "StartDate" => start_date,
      "EndDate" => end_date,
#        "SearchTerms" => "",
      "Take" => 1000, 
      "TicketStatuses" => [status].flatten, # Need to flatten in case we're getting an array of statuses passed, since we don't want to pass Dragon an array of an array
      "ShowAllYards" => true # Pass back tickets from all yards
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    
    data= Hash.from_xml(xml_content)
#    Rails.logger.info data
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.find_by_id(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    return data["ApiItemResponseOfApiTicketHead0UdNujZ0"]["Item"]
  end
  
  def self.get_ticket(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket/getticket"
    payload = {
      "sessionId" => "",
      "itemId" => ticket_id,
      "isSessionTakeover" => false,
      "skipSessionValidation" => false
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Ticket.get_ticket response: #{data}"
    unless data["ApiGetTicketByIdResponse"].blank?
      return data["ApiGetTicketByIdResponse"]
    else
      nil
    end
  end
  
  def self.get_ticket_with_session(auth_token, yard_id, ticket_id, session_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket/getticket"
    payload = {
      "sessionId" => session_id,
      "itemId" => ticket_id,
      "isSessionTakeover" => false,
      "skipSessionValidation" => false
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Ticket.get_ticket response: #{data}"
    unless data["ApiGetTicketByIdResponse"].blank?
      return data["ApiGetTicketByIdResponse"]
    else
      nil
    end
  end
  
  def self.release_session(auth_token, session_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/sessions/removesession"
    payload = {
      "sessionId" => session_id
      }
    json_encoded_payload = JSON.generate(payload)
    xml_content = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Ticket.release_session response: #{data}"
#    unless data["ApiGetTicketByIdResponse"].blank?
#      return data["ApiGetTicketByIdResponse"]
#    else
#      nil
#    end
  end
  
  def self.search(status, auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=60&t=100")
    api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/#{status}?q=#{query_string}&d=1200&t=100")
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
    if data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      return data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
  end
  
  def self.search_all_statuses(auth_token, yard_id, query_string)
    require 'uri'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    closed_api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/1?q=#{query_string}&d=100&t=100")
    held_api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/2?q=#{query_string}&d=100&t=100")
    paid_api_url = URI.encode("https://#{user.company.dragon_api}/api/yard/#{yard_id}/tickets/3?q=#{query_string}&d=100&t=100")
    
    closed_xml_content = RestClient::Request.execute(method: :get, url: closed_api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    closed_data= Hash.from_xml(closed_xml_content)
    held_xml_content = RestClient::Request.execute(method: :get, url: held_api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    held_data= Hash.from_xml(held_xml_content)
    paid_xml_content = RestClient::Request.execute(method: :get, url: paid_api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    paid_data= Hash.from_xml(paid_xml_content)
    
    if closed_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      closed_tickets = [closed_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      closed_tickets =  closed_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
    
    if held_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      held_tickets = [held_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      held_tickets =  held_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
    
    if paid_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"].is_a? Hash # Only one result returned, so put it into an array
      paid_tickets = [paid_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]]
    else # Array of results returned
      paid_tickets =  paid_data["ApiPaginatedResponseOfApiTicketHead0UdNujZ0"]["Items"]["ApiTicketHead"]
    end
    
    if closed_tickets.blank?
      closed_tickets = []
    end
    if held_tickets.blank?
      held_tickets = []
    end
    if paid_tickets.blank?
      paid_tickets = []
    end
    
    return closed_tickets + held_tickets + paid_tickets
  end
  
  # Get next available ticket number
  def self.next_available_number(auth_token, yard_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/nextnumber"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemResponseOfApiUniqueNumbermHEMxW_SG"]["Item"]["Value"]
  end
  
  # Get Scrap Dragon units of measure
  def self.units_of_measure(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/uom"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
    
    data["ApiItemsResponseOfApiUnitOfMeasureia6G0PzH"]["Items"]["ApiUnitOfMeasure"]
  end
  
  # Create a new ticket
  def self.create(auth_token, yard_id, customer_id, guid, related_workorder_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    ticket_number = Ticket.next_available_number(auth_token, yard_id)
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "TicketHead" => {
          "Id" => guid,
          "Description" => "",
          "YardId" => yard_id,
          "CustomerId" => customer_id,
          "FirstName" => customer['FirstName'],
          "LastName" => customer['LastName'],
          "Company" => customer['Company'],
          "PayToId" => customer_id,
          "TicketNumber" => ticket_number,
          "Status" => 2,
          "CurrencyId" => user.user_setting.currency_id,
          "PrintPrices" => true,
          "DateCreated" => Time.now.utc,
          "RelatedWorkOrderId" => related_workorder_id
          }
        })
      
#      Rails.logger.info "Ticket.create response: #{response}"
      data= Hash.from_xml(response)
      return data["SaveTicketResponse"]["Success"]
  end
  
  # Update an existing ticket
  def self.update(auth_token, yard_id, customer_id, guid, ticket_number, status, description)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    ticket = Ticket.find_by_id(auth_token, yard_id, guid)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "TicketHead" => {
          "Id" => guid,
          "Description" => description,
          "YardId" => yard_id,
          "CustomerId" => customer_id,
          "FirstName" => customer.blank? ? "" : customer['FirstName'],
          "LastName" => customer.blank? ? "" : customer['LastName'],
          "Company" => customer.blank? ? "" : customer['Company'],
          "PayToId" => customer_id,
          "TicketNumber" => ticket_number,
          "Status" => status,
          "CurrencyId" => user.user_setting.currency_id,
          "VoidedByUserId" => "91560F2C-C390-45B3-B0DE-B64C2DA255C5",
          "PrintPrices" => true,
          "DateCreated" =>  ticket['DateCreated'],
          "DateClosed" =>  Time.now.utc,
          "RelatedWorkOrderId" =>  ticket['RelatedWorkOrderId'],
          }
        })
      
#      Rails.logger.info "Ticket update response: #{response}"
      data= Hash.from_xml(response)
#      return data["SaveTicketResponse"]["Success"]
      return data["SaveTicketResponse"]
  end
  
  # Save an existing ticket with session
  def self.save_with_session(auth_token, yard_id, customer_id, guid, ticket_number, status, description, session_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket"
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    ticket = Ticket.find_by_id(auth_token, yard_id, guid)
    payload = {
      "sessionId" => session_id,
      "skipSessionValidation" => false,
      "TicketHead" => {
        "Id" => guid,
        "Description" => description,
        "YardId" => yard_id,
        "CustomerId" => customer_id,
        "FirstName" => customer.blank? ? "" : customer['FirstName'],
        "LastName" => customer.blank? ? "" : customer['LastName'],
        "Company" => customer.blank? ? "" : customer['Company'],
        "PayToId" => customer_id,
        "TicketNumber" => ticket_number,
        "Status" => status,
        "BalanceDue" => ticket['BalanceDue'],
        "CurrencyId" => user.user_setting.currency_id,
        "VoidDate" => nil,
        "VoidedByUserId" => nil,
        "UserId" => ticket['UserId'],
        "JobNumber" => "",
        "BolNumber" => "",
        "PrintPrices" => true,
        "DateCreated" =>  ticket['DateCreated'],
        "DateClosed" =>  Time.now.utc,
        "RelatedWorkOrderId" =>  ticket['RelatedWorkOrderId'],
        }
      }
    json_encoded_payload = JSON.generate(payload)
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
#    Rails.logger.info "Ticket.save_with_session response: #{response}"
    data= Hash.from_xml(response)
#    return data["ApiSaveTicketResponse"]["Success"]
    return data["ApiSaveTicketResponse"]
  end
  
  # Void a ticket
#  def self.void(auth_token, yard_id, ticket)
  def self.void(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "TicketHead" => {
          "Id" => ticket['Id'],
          "Description" => ticket['Description'],
          "YardId" => yard_id,
          "CustomerId" => ticket['CustomerId'],
          "PayToId" => ticket['CustomerId'],
          "Status" => 5,
          "CurrencyId" => user.user_setting.currency_id,
          "VoidedByUserId" => "91560F2C-C390-45B3-B0DE-B64C2DA255C5",
          "DateClosed" =>  Time.now.utc
          }
        })
      
#      Rails.logger.info "Ticket void response: #{response}"
      data= Hash.from_xml(response)
      return data["SaveTicketResponse"]["Success"]
  end
  
  def self.void_with_session(auth_token, yard_id, ticket_id, session_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket"
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket"
    payload = {
      "sessionId" => session_id,
      "skipSessionValidation" => false,
      "TicketHead" => {
        "Id" => ticket_id,
        "Description" => ticket["Description"],
        "YardId" => yard_id,
        "CustomerId" => ticket["CustomerId"],
        "TicketNumber" => ticket["TicketNumber"],
        "Status" => 5,
        "BalanceDue" => ticket['BalanceDue'],
        "CurrencyId" => user.user_setting.currency_id,
        "VoidDate" => nil,
        "VoidedByUserId" => nil,
        "UserId" => ticket['UserId'],
        "JobNumber" => "",
        "BolNumber" => "",
        "PrintPrices" => true,
        "DateCreated" =>  ticket['DateCreated'],
        "DateClosed" =>  Time.now.utc,
        "RelatedWorkOrderId" =>  ticket['RelatedWorkOrderId'],
        }
      }
      json_encoded_payload = JSON.generate(payload)
      response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
#      Rails.logger.info "Ticket.void_with_session response: #{response}"
      data= Hash.from_xml(response)
      return data["ApiSaveTicketResponse"]["Success"]
  end
  
  # Add a line item to a ticket
  def self.add_item(auth_token, yard_id, ticket_id, item_id, commodity_id, quantity, gross, tare, net, price, amount, notes, serial_number, customer_id, unit_of_measure, deductions)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
#    new_id = SecureRandom.uuid
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    taxes = Commodity.taxes_by_customer(auth_token, commodity_id, customer_id)
#    taxes = Commodity.taxes_by_customer(auth_token, commodity_id, "6b5c0f91-e9db-430d-b9d3-5937a15bcdea")
    tax_collection_array = []
    unless taxes.blank?
      taxes.each do |tax|
        tax_amount = (tax['TaxPercent'].to_f/100 * amount.to_f)
        tax_hash = {
          "Id" => SecureRandom.uuid,
          "TicketItemId" => new_id,
          "SalesTaxId" => tax['Id'],
          "TaxName" => tax['TaxName'],
          "TaxPercent" => tax['TaxPercent'],
          "TaxAmount" => tax_amount,
          "TaxAmountInAssignedCurrency" => tax_amount,
          "CustomerRateOverride" => false,
          "TaxCode" => tax['TaxCode'],
          "CurrencyId" => user.user_setting.currency_id,
          "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
        }
        tax_collection_array << tax_hash
      end
    end
    
    deductions_collection_array = []
    unless deductions.blank?
      deductions.each do |deduction|
        unless (deduction[:deduct_weight_description].blank? and deduction[:deduct_dollar_amount_description].blank?) or (deduction[:deduct_weight].blank? and deduction[:deduct_dollar_amount].blank?) 
          deduction_hash = {
              "id" => SecureRandom.uuid,
              "ticketItemId" => new_id,
              "deductWeight" => deduction[:deduct_weight].blank? ? '' : deduction[:deduct_weight],
              "deductWeightDescription" => deduction[:deduct_weight_description].blank? ? '' : deduction[:deduct_weight_description],
              "deductDollarAmount" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountInAssignedCurrency" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountDescription" => deduction[:deduct_dollar_amount_description].blank? ? '' : deduction[:deduct_dollar_amount_description],
              "status" => 0,
              "type" => 0,
              "percentageAmount" => 0,
              "currencyId" => user.user_setting.currency_id
            }
            deductions_collection_array << deduction_hash
        end
      end
    end
    
    payload = {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "DateCreated" => Time.now.utc.iso8601, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => quantity,
          "GrossWeight" => gross,
#          "Id" => new_id,
          "Id" => item_id,
          "NetWeight" => net,
          "Notes" => notes, 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => serial_number, 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => unit_of_measure,
          "TaxCollection" => tax_collection_array,
          "deductionCollection" => deductions_collection_array
          }
        }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.debug "******************* The Payload: #{json_encoded_payload}"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
      
    data= Hash.from_xml(response)
    return data["SaveTicketItemResponse"]["Success"]
  end
   
  # Update line item of ticket
  def self.update_item(auth_token, yard_id, ticket_id, item_id, commodity_id, quantity, gross, tare, net, price, amount, notes, serial_number, customer_id, unit_of_measure, deductions)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
    taxes = Commodity.taxes_by_customer(auth_token, commodity_id, customer_id)

    tax_collection_array = []
    unless taxes.blank?
      # Get line item's current taxes to zero-out
      if ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
         # Only one line item in the ticket
         line_item = ticket["TicketItemCollection"]["ApiTicketItem"]
      else
         # Multiple line items in the ticket
        line_item = ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Id"] == item_id}.first
      end
      unless line_item.blank? or line_item['TaxCollection'].blank? # This line item doesn't have any taxes
        unless line_item['TaxCollection']['ApiTicketItemTax'].is_a? Hash
          # Multiple taxes on line item
          line_item['TaxCollection']['ApiTicketItemTax'].each do |tax|
            tax_hash = {
              "Id" => tax['Id'],
              "TicketItemId" => item_id,
              "SalesTaxId" => tax['SalesTaxId'],
              "TaxName" => tax['TaxName'],
              "TaxPercent" => 0,
              "TaxAmount" => 0,
              "TaxAmountInAssignedCurrency" => 0,
              "CustomerRateOverride" => false,
              "TaxCode" => tax['TaxCode'],
              "CurrencyId" => user.user_setting.currency_id,
              "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
            }
            tax_collection_array << tax_hash
          end
        else
          # One tax on line item
          tax_hash = {
            "Id" => line_item['TaxCollection']['ApiTicketItemTax']['Id'],
            "TicketItemId" => item_id,
            "SalesTaxId" => line_item['TaxCollection']['ApiTicketItemTax']['SalesTaxId'],
            "TaxName" => line_item['TaxCollection']['ApiTicketItemTax']['TaxName'],
            "TaxPercent" => 0,
            "TaxAmount" => 0,
            "TaxAmountInAssignedCurrency" => 0,
            "CustomerRateOverride" => false,
            "TaxCode" => line_item['TaxCollection']['ApiTicketItemTax']['TaxCode'],
            "CurrencyId" => user.user_setting.currency_id,
            "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
            }
            tax_collection_array << tax_hash
        end
      end
      
      taxes.each do |tax|
        tax_amount = (tax['TaxPercent'].to_f/100 * amount.to_f)
        tax_hash = {
          "Id" => SecureRandom.uuid,
          "TicketItemId" => item_id,
          "SalesTaxId" => tax['Id'],
          "TaxName" => tax['TaxName'],
          "TaxPercent" => tax['TaxPercent'],
          "TaxAmount" => tax_amount,
          "TaxAmountInAssignedCurrency" => tax_amount,
          "CustomerRateOverride" => false,
          "TaxCode" => tax['TaxCode'],
          "CurrencyId" => user.user_setting.currency_id,
          "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
        }
        tax_collection_array << tax_hash
      end
    end
    
    deductions_collection_array = []
    unless deductions.blank?
      deductions.each do |deduction|
        unless (deduction[:deduct_weight_description].blank? and deduction[:deduct_dollar_amount_description].blank?) or (deduction[:deduct_weight].blank? and deduction[:deduct_dollar_amount].blank?) 
          deduction_hash = {
              "id" => deduction[:id].blank? ? SecureRandom.uuid : deduction[:id],
              "ticketItemId" => item_id,
              "deductWeight" => deduction[:deduct_weight].blank? ? '' : deduction[:deduct_weight],
              "deductWeightDescription" => deduction[:deduct_weight_description].blank? ? '' : deduction[:deduct_weight_description],
              "deductDollarAmount" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountInAssignedCurrency" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountDescription" => deduction[:deduct_dollar_amount_description].blank? ? '' : deduction[:deduct_dollar_amount_description],
              "status" => 0,
              "type" => 0,
              "percentageAmount" => 0,
              "currencyId" => user.user_setting.currency_id
            }
            deductions_collection_array << deduction_hash
        end
      end
    end
    
    payload = {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => quantity,
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => notes, 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => serial_number, 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => unit_of_measure,
          "TaxCollection" => tax_collection_array,
          "deductionCollection" => deductions_collection_array
          }
        }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.debug "******************* The Payload: #{json_encoded_payload}"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
      
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Void/remove a line item from ticket
  def self.void_item(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/void"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id,
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => '0',
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
#      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  def self.add_item_with_session(auth_token, yard_id, ticket_id, item_id, commodity_id, quantity, gross, tare, net, price, amount, notes, serial_number, customer_id, unit_of_measure, deductions, session_id)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket/item"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    taxes = Commodity.taxes_by_customer(auth_token, commodity_id, customer_id)
    tax_collection_array = []
    unless taxes.blank?
      taxes.each do |tax|
        tax_amount = (tax['TaxPercent'].to_f/100 * amount.to_f)
        tax_hash = {
          "Id" => SecureRandom.uuid,
          "TicketItemId" => new_id,
          "SalesTaxId" => tax['Id'],
          "TaxName" => tax['TaxName'],
          "TaxPercent" => tax['TaxPercent'],
          "TaxAmount" => tax_amount,
          "TaxAmountInAssignedCurrency" => tax_amount,
          "CustomerRateOverride" => false,
          "TaxCode" => tax['TaxCode'],
          "CurrencyId" => user.user_setting.currency_id,
          "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
        }
        tax_collection_array << tax_hash
      end
    end
    
    deductions_collection_array = []
    unless deductions.blank?
      deductions.each do |deduction|
        unless (deduction[:deduct_weight_description].blank? and deduction[:deduct_dollar_amount_description].blank?) or (deduction[:deduct_weight].blank? and deduction[:deduct_dollar_amount].blank?) 
          deduction_hash = {
              "id" => SecureRandom.uuid,
              "ticketItemId" => new_id,
              "deductWeight" => deduction[:deduct_weight].blank? ? '' : deduction[:deduct_weight],
              "deductWeightDescription" => deduction[:deduct_weight_description].blank? ? '' : deduction[:deduct_weight_description],
              "deductDollarAmount" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountInAssignedCurrency" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountDescription" => deduction[:deduct_dollar_amount_description].blank? ? '' : deduction[:deduct_dollar_amount_description],
              "status" => 0,
              "type" => 0,
              "percentageAmount" => 0,
              "currencyId" => user.user_setting.currency_id
            }
            deductions_collection_array << deduction_hash
        end
      end
    end
    
    payload = {
        "sessionId" => session_id,
        "skipSessionValidation" => false,
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "DateCreated" => Time.now.utc.iso8601, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => quantity,
          "GrossWeight" => gross,
#          "Id" => new_id,
          "Id" => item_id,
          "NetWeight" => net,
          "Notes" => notes, 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => serial_number, 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => unit_of_measure,
          "TaxCollection" => tax_collection_array,
          "deductionCollection" => deductions_collection_array
          }
        }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.debug "******************* The Payload: #{json_encoded_payload}"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
#    Rails.logger.debug "Ticket.add_item_with_session response: #{response}"
    data= Hash.from_xml(response)
    return data["ApiSaveTicketItemResponse"]["Success"]
  end
  
  def self.update_item_with_session(auth_token, yard_id, ticket_id, item_id, commodity_id, quantity, gross, tare, net, price, amount, notes, serial_number, customer_id, unit_of_measure, deductions, session_id)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item"
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket/item"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
    taxes = Commodity.taxes_by_customer(auth_token, commodity_id, customer_id)

    tax_collection_array = []
    unless taxes.blank?
      # Get line item's current taxes to zero-out
      if ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
         # Only one line item in the ticket
         line_item = ticket["TicketItemCollection"]["ApiTicketItem"]
      else
         # Multiple line items in the ticket
        line_item = ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Id"] == item_id}.first
      end
      unless line_item.blank? or line_item['TaxCollection'].blank? # This line item doesn't have any taxes
        unless line_item['TaxCollection']['ApiTicketItemTax'].is_a? Hash
          # Multiple taxes on line item
          line_item['TaxCollection']['ApiTicketItemTax'].each do |tax|
            tax_hash = {
              "Id" => tax['Id'],
              "TicketItemId" => item_id,
              "SalesTaxId" => tax['SalesTaxId'],
              "TaxName" => tax['TaxName'],
              "TaxPercent" => 0,
              "TaxAmount" => 0,
              "TaxAmountInAssignedCurrency" => 0,
              "CustomerRateOverride" => false,
              "TaxCode" => tax['TaxCode'],
              "CurrencyId" => user.user_setting.currency_id,
              "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
            }
            tax_collection_array << tax_hash
          end
        else
          # One tax on line item
          tax_hash = {
            "Id" => line_item['TaxCollection']['ApiTicketItemTax']['Id'],
            "TicketItemId" => item_id,
            "SalesTaxId" => line_item['TaxCollection']['ApiTicketItemTax']['SalesTaxId'],
            "TaxName" => line_item['TaxCollection']['ApiTicketItemTax']['TaxName'],
            "TaxPercent" => 0,
            "TaxAmount" => 0,
            "TaxAmountInAssignedCurrency" => 0,
            "CustomerRateOverride" => false,
            "TaxCode" => line_item['TaxCollection']['ApiTicketItemTax']['TaxCode'],
            "CurrencyId" => user.user_setting.currency_id,
            "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
            }
            tax_collection_array << tax_hash
        end
      end
      
      taxes.each do |tax|
        tax_amount = (tax['TaxPercent'].to_f/100 * amount.to_f)
        tax_hash = {
          "Id" => SecureRandom.uuid,
          "TicketItemId" => item_id,
          "SalesTaxId" => tax['Id'],
          "TaxName" => tax['TaxName'],
          "TaxPercent" => tax['TaxPercent'],
          "TaxAmount" => tax_amount,
          "TaxAmountInAssignedCurrency" => tax_amount,
          "CustomerRateOverride" => false,
          "TaxCode" => tax['TaxCode'],
          "CurrencyId" => user.user_setting.currency_id,
          "DateApplied" => Time.now.utc.iso8601 # Remove the UTC from the end
        }
        tax_collection_array << tax_hash
      end
    end
    
    deductions_collection_array = []
    unless deductions.blank?
      deductions.each do |deduction|
        unless (deduction[:deduct_weight_description].blank? and deduction[:deduct_dollar_amount_description].blank?) or (deduction[:deduct_weight].blank? and deduction[:deduct_dollar_amount].blank?) 
          deduction_hash = {
              "id" => deduction[:id].blank? ? SecureRandom.uuid : deduction[:id],
              "ticketItemId" => item_id,
              "deductWeight" => deduction[:deduct_weight].blank? ? '' : deduction[:deduct_weight],
              "deductWeightDescription" => deduction[:deduct_weight_description].blank? ? '' : deduction[:deduct_weight_description],
              "deductDollarAmount" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountInAssignedCurrency" => deduction[:deduct_dollar_amount].blank? ? 0 : deduction[:deduct_dollar_amount],
              "deductDollarAmountDescription" => deduction[:deduct_dollar_amount_description].blank? ? '' : deduction[:deduct_dollar_amount_description],
              "status" => 0,
              "type" => 0,
              "percentageAmount" => 0,
              "currencyId" => user.user_setting.currency_id
            }
            deductions_collection_array << deduction_hash
        end
      end
    end
    
    payload = {
        "sessionId" => session_id,
        "skipSessionValidation" => false,
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id, 
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => quantity,
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => notes, 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => serial_number, 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => unit_of_measure,
          "TaxCollection" => tax_collection_array,
          "deductionCollection" => deductions_collection_array
          }
        }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.debug "******************* The Payload: #{json_encoded_payload}"
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
#      Rails.logger.debug "Ticket.update_item_with_session response: #{response}"
      data= Hash.from_xml(response)
      return data["ApiSaveTicketItemResponse"]["Success"]
  end
  
  def self.void_item_with_session(auth_token, yard_id, ticket_id, item_id, commodity_id, gross, tare, net, price, amount, session_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
#    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/item/void"
    api_url = "https://#{user.company.dragon_api}/api/v1/yard/#{yard_id}/ticket/item/void"
    commodity = Commodity.find_by_id(auth_token, yard_id, commodity_id)
    commodity_name = commodity["PrintDescription"]
    commodity_unit_of_measure = commodity["UnitOfMeasure"]
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"},
      payload: {
        "sessionId" => session_id,
        "skipSessionValidation" => false,
        "TicketItem"=>{
          "CommodityId" => commodity_id,
          "CurrencyId" => user.user_setting.currency_id,
          "ExtendedAmount" => amount, 
          "ExtendedAmountInAssignedCurrency" => amount,
          "Quantity" => '0',
          "GrossWeight" => gross,
          "Id" => item_id, 
          "NetWeight" => net,
          "Notes" => "", 
          "Price" => price,
          "PriceInAssignedCurrency" => price,
          "PrintDescription" => commodity_name, 
          "ScaleUnitOfMeasure" => "LB", 
          "Sequence" => "1", 
          "SerialNumber" => "", 
          "Status" => 'Hold', 
          "TareWeight" => tare, 
          "TicketHeadId" => ticket_id,
          "UnitOfMeasure" => "LB"
          }
        })
#      Rails.logger.info response
      data= Hash.from_xml(response)
      return data["SaveTicketItemResponse"]["Success"]
  end
  
  # Get accounts payable items for ticket (multiple items if partial payments)
  def self.accounts_payable_items(auth_token, yard_id, ticket_id)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem"
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "********************#{data}****************"
    if data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]]
    else # Array of results returned
      # This will only be more than one if this is a preexisting ticket that had a payment split or payment was split by the device.
      return data["ApiItemsResponseOfApiAccountsPayableLineItem0UdNujZ0"]["Items"]["ApiAccountsPayableLineItem"]
    end
  end
  
  # Pay ticket by cash
  def self.pay_by_cash(auth_token, yard_id, ticket_id, accounts_payable_id, drawer_id, amount)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem/#{accounts_payable_id}/pay"
    accounts_payable_line_item = Ticket.accounts_payable_items(auth_token, yard_id, ticket_id).last
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=nil  if v == {"i:nil"=>"true"} }
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=""  if v == nil }
    payload = {
      "AccountsPayableLineItem" => accounts_payable_line_item,
      "PaymentMethod" => 0,
      "DrawerId" => drawer_id,
      "Check" => nil
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
      
    data= Hash.from_xml(response)
#    Rails.logger.info "******************* Pay by cash: #{data} *******************************"
#    return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]["Success"]
    return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]
  end
  
  # Pay ticket by check
  def self.pay_by_check(auth_token, yard_id, ticket_id, accounts_payable_id, drawer_id, check_id, check_account_name, check_number, amount)
    require 'json'
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/yard/#{yard_id}/ticket/#{ticket_id}/aplineitem/#{accounts_payable_id}/pay"
    accounts_payable_line_item = Ticket.accounts_payable_items(auth_token, yard_id, ticket_id).last
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=nil  if v == {"i:nil"=>"true"} }
    accounts_payable_line_item.each {|k,v| accounts_payable_line_item[k]=""  if v == nil }
    payload = {
      "AccountsPayableLineItem" => accounts_payable_line_item,
      "PaymentMethod" => 1,
      "DrawerId" => drawer_id,
      "Check" => { 
        "Id" => SecureRandom.uuid,
        "AccountsPayableCashierId" => nil, 
        "CheckAccountId" => check_id,
        "CheckNumber" => check_number,
        "Amount" => amount,
        "PayToTheOrderOf" => "", 
        "Memo" => "ticket ID: #{ticket_id}",
        "Company" => "",
        "Address1" => "",
        "Address2" => "",
        "City" => "",
        "State" => "",
        "Zip" => "",
        "CheckStatus" => "",
        "CheckAccountName" => check_account_name,
        "CurrencyId" => user.user_setting.currency_id,
        "CurrencyConversionFactor" => ""
        }
      }
    json_encoded_payload = JSON.generate(payload)
#    Rails.logger.info json_encoded_payload
    response = RestClient::Request.execute(method: :post, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :content_type => 'application/json', :Accept => "application/xml"},
      payload: json_encoded_payload)
      
    data= Hash.from_xml(response)
#    Rails.logger.info "******************* Pay by check: #{data} *******************************"
#    return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]["Success"]
    return data["ApiItemResponseOfApiAccountsPayableCashierFk1NORs_P"]
  end
  
  def self.total_paid(auth_token, yard_id, ticket_id)
    accounts_payables = AccountsPayable.all(auth_token, yard_id, ticket_id)
    sum = 0
    unless accounts_payables.blank?
      accounts_payables.each do |accounts_payable|
        sum = sum + accounts_payable["PaidAmount"].to_d
      end
    end
    return sum
  end
  
  def self.commodities(status, auth_token, yard_id, ticket_id)
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
    commodities = []
    unless ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
      # Multiple ticket line items
      ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'}.each do |commodity|
        commodities << Commodity.find_by_id(auth_token, yard_id, commodity["CommodityId"])
      end
    else
      # Only one ticket line item
      commodities << Commodity.find_by_id(auth_token, yard_id, ticket["TicketItemCollection"]["ApiTicketItem"]["CommodityId"])
    end
    return commodities
  end
  
  def self.line_items(api_ticket_item)
    line_items = []
    unless api_ticket_item.is_a? Hash
      # Multiple ticket line items
      api_ticket_item.select{|i| i["Status"] == '0'}.each do |line_item|
        line_items << line_item
      end
    else
      # Only one ticket line item
      line_items << api_ticket_item
    end
    return line_items
  end
  
  def self.line_items_total(api_ticket_item)
    unless api_ticket_item.is_a? Hash
      # Multiple ticket line items
      total = 0
      api_ticket_item.select{|i| i["Status"] == '0'}.each do |line_item|
        total = total + line_item['ExtendedAmount'].to_d
        # Add in any taxes
        unless line_item['TaxCollection'].blank?
          if line_item['TaxCollection']['ApiTicketItemTax'].is_a? Hash # Only one line item tax result returned
            unless line_item['TaxCollection']['ApiTicketItemTax']['TaxAmount'] == '0.00'
              total = total + line_item['TaxCollection']['ApiTicketItemTax']['TaxAmount'].to_d
            end
          else # Multiple line item tax results returned
            line_item['TaxCollection']['ApiTicketItemTax'].each do |tax|
              unless tax['TaxAmount'] == '0.00'
                total = total + tax['TaxAmount'].to_d
              end
            end
          end
        end
      end
    else
      # Only one ticket line item
      total = api_ticket_item['ExtendedAmount'].to_d
      # Add in any taxes
      unless api_ticket_item['TaxCollection'].blank?
        if api_ticket_item['TaxCollection']['ApiTicketItemTax'].is_a? Hash # Only one line item tax result returned
          unless api_ticket_item['TaxCollection']['ApiTicketItemTax']['TaxAmount'] == '0.00'
            total = total + api_ticket_item['TaxCollection']['ApiTicketItemTax']['TaxAmount'].to_d
          end
        else # Multiple line item tax results returned
          api_ticket_item['TaxCollection']['ApiTicketItemTax'].each do |tax|
            unless tax['TaxAmount'] == '0.00'
              total = total + tax['TaxAmount'].to_d
            end
          end
        end
      end
    end
    return total
  end
  
  def self.currencies(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/currency"
    
    xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", :Accept => "application/xml"})
    data= Hash.from_xml(xml_content)
#    Rails.logger.info "Ticket.currencies response: #{data}"
    
    if data["ApiItemsResponseOfCurrencyInformationb_S917hz8"]["Items"]["CurrencyInformation"].is_a? Hash # Only one result returned, so put it into an array
      return [data["ApiItemsResponseOfCurrencyInformationb_S917hz8"]["Items"]["CurrencyInformation"]]
    else # Array of results returned
      return data["ApiItemsResponseOfCurrencyInformationb_S917hz8"]["Items"]["CurrencyInformation"]
    end
  end

  def self.generate_leads_online_xml(auth_token, ticket_id, yard_id, user, customer_id, images)
    yard = Yard.find_by_id(auth_token, yard_id)
    ticket = Ticket.find_by_id(auth_token, yard_id, ticket_id)
    customer = Customer.find_by_id(auth_token, yard_id, customer_id)
    xml = ::Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.LeadsOnlineUpload do
      xml.software do
        xml.name("Portal")
        xml.version("1.0")
      end
      xml.store_info do
        xml.company_nm(user.company.name)
        xml.store_number(yard_id)
        xml.store_nm(yard['Name'])
        xml.store_addr1(yard['Address1'])
        xml.store_addr2(yard['Address2'])
        xml.store_city(yard['City'])
        xml.store_state(yard['State'])
        xml.store_zip(yard['Division'])
        xml.store_county
        xml.store_phone
      end
      xml.tickets do
        xml.ticket do
          xml.ticket_number(ticket["TicketNumber"])
          xml.enter_date(ticket["DateCreated"])
          xml.clerk(user.email)
          xml.void("N")
          xml.customer do
            xml.cust_nm_last(customer['LastName'])
            xml.cust_nm_first(customer['FirstName'])
            xml.cust_nm_middle
            xml.cust_nm_suffix
            xml.cust_addr1(customer['Address1'])
            xml.cust_addr2(customer['Address2'])
            xml.cust_city(customer['City'])
            xml.cust_state(customer['State'])
            xml.cust_zip(customer['Zip'])
            xml.cust_phone(customer['Phone'])
            xml.cust_id_type("DL")
            xml.cust_id_state(customer['IdState'])
            xml.cust_id_number(customer['IdNumber'])
            unless customer['IdExpires'] == {"i:nil"=>"true"}
              xml.cust_id_exp(customer['IdExpires'].to_date.strftime("%Y-%m-%d"))
            else
              xml.cust_id_exp
            end
            xml.cust_birthdate
            xml.cust_weight
            xml.cust_height
            xml.cust_eye
            xml.cust_hair
            xml.cust_race
            xml.cust_sex
            xml.cust_info
            xml.cust_picture(:code => "C")
            xml.cust_picture(:code => "I")
            xml.cust_picture(:code => "T")
            xml.cust_picture(:code => "S")
            xml.employer_nm(customer['Company'])
            xml.employer_addr1
            xml.employer_addr2
            xml.employer_city
            xml.employer_state
            xml.employer_zip
            xml.employer_phone
          end
          xml.vehicle do
            xml.vehicle_license
            xml.vehicle_license_state
            xml.vehicle_license_exp
            xml.vehicle_make
            xml.vehicle_model
            xml.vehicle_year
            xml.vehicle_color
            xml.trailer_desc
            xml.trailer_color
            xml.trailer_license
            xml.trailer_license_state
            xml.trailer_license_exp
            xml.vehicle_picture(:code => "V")
            xml.vehicle_picture(:code => "L")
          end
          xml.property do
            unless ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
              ticket["TicketItemCollection"]["ApiTicketItem"].each_with_index do |line_item, index|
                xml.item do
                  xml.item_number(line_item['Id'])
                  xml.item_make
                  xml.item_model
                  xml.item_serial
                  xml.item_color
                  xml.item_condition
                  xml.item_volts
                  xml.item_amps
                  xml.item_desc(line_item["PrintDescription"])
                  xml.item_notes
                  xml.item_net_wt(line_item['NetWeight'])
                  xml.item_amount(line_item['ExtendedAmount'])
                  xml.item_received_title("N")
                  if index == 0
                    unless images.blank?
                      images.each do |image|
                        xml.item_picture(image.jpeg_image_base_64, :code => "A", :type => 'jpg')
                      end
                    end
                  end
                end
              end
            else
              xml.item do
                xml.item_number(ticket["TicketItemCollection"]["ApiTicketItem"]['Id'])
                xml.item_make
                xml.item_model
                xml.item_serial
                xml.item_color
                xml.item_condition
                xml.item_volts
                xml.item_amps
                xml.item_desc(ticket["TicketItemCollection"]["ApiTicketItem"]["PrintDescription"])
                xml.item_notes
                xml.item_net_wt(ticket["TicketItemCollection"]["ApiTicketItem"]['NetWeight'])
                xml.item_amount(ticket["TicketItemCollection"]["ApiTicketItem"]['ExtendedAmount'])
                xml.item_received_title("N")
                unless images.blank?
                  images.each do |image|
                    xml.item_picture(image.jpeg_image_base_64, :code => "A", :type => 'jpg')
                  end
                end
              end
            end
          end
        end
      end
    end
    
  end
  
  def self.customer_summary_to_csv(tickets_array)
    require 'csv'
#    headers = ['DateCreated', 'TicketNumber', 'BalanceDue', 'Company', 'FirstName', 'LastName']
    headers = ['DateCreated', 'TicketNumber', 'Customer', 'Status', 'Amount']
    
    CSV.generate(headers: true) do |csv|
      csv << headers

      tickets_array.each do |ticket|
#        csv << headers.map{ |attr| ticket[attr] }
        date_created = ticket['DateCreated']
        ticket_number = ticket['TicketNumber']
        customer_name = "#{ticket['FirstName']} #{ticket['LastName']}"
        company_name = ticket['Company']
        name = company_name.blank? ? customer_name : company_name
        status = ApplicationController.helpers.ticket_status_string(ticket['Status'])
        amount = "#{ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank? ? 'N/A' : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])}"
        csv << [date_created, ticket_number, name, status, amount]
      end
    end
  end
  
  def self.v2_customer_summary_to_csv(tickets_array)
    require 'csv'
    headers = ['DateCreated', 'TicketNumber', 'Customer', 'Status', 'Amount']
    
    CSV.generate(headers: true) do |csv|
      csv << headers

      tickets_array.each do |ticket|
        date_created = ticket.date_created
        ticket_number = ticket.ticket_number
        customer_name = "#{ticket.customer.first_name} #{ticket.customer.last_name}"
        company_name = ticket.customer.company
        name = company_name.blank? ? customer_name : company_name
        status = ticket.ticket_status
        amount = "#{ticket.ticket_items.blank? ? 'N/A' : Ticket.v2_line_items_total(ticket.ticket_items)}"
        csv << [date_created, ticket_number, name, status, amount]
      end
    end
  end
  
  def self.commodity_summary_to_csv(line_items_array, tickets_array)
    require 'csv'
#    headers = ['DateCreated', 'Description', 'Ticket', 'Job', 'BOL', 'PO', 'Customer', 'Customer Ref #', 'Customer Ship', 'PrintDescription', 'GrossWeight', 'TareWeight', 'NetWeight', 'Price', 'ExtendedAmount']
    headers = ['DateCreated', 'Commodity', 'Ticket', 'Customer', 'Status', 'GrossWeight', 'TareWeight', 'NetWeight', 'Price', 'ExtendedAmount']
    
    CSV.generate(headers: true) do |csv|
      csv << headers
#      net_total = 0
#      extended_amount_total = 0
      line_items_array.each do |line_item|
        date_created = line_item['DateCreated']
#        description = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["Description"] rescue ''
        ticket_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["TicketNumber"] rescue ''
#        job_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["JobNumber"] rescue ''
#        bol_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["BolNumber"] rescue ''
#        purchase_order_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["PurchaseOrderNumber"] rescue ''
        customer_name = "#{tickets_array.find {|ticket| ticket['Id'] == line_item['TicketHeadId']}['FirstName']} #{tickets_array.find {|ticket| ticket['Id'] == line_item['TicketHeadId']}['LastName']}"
        company_name = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["Company"]
        name = company_name.blank? ? customer_name : company_name
#        customer_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["CustomerReferenceNumber"] rescue ''
#        customer_ship_date = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["CustomerShipDate"] rescue ''
        print_description = line_item['PrintDescription']
        status = ApplicationController.helpers.ticket_status_string(tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["Status"]) rescue ''
        gross_weight = line_item['GrossWeight']
        tare_weight = line_item['TareWeight']
        net_weight = line_item['NetWeight']
        price = "#{line_item['Price']} #{line_item['UnitOfMeasure']}"
        extended_amount = line_item['ExtendedAmount']
        
#        net_total = net_total + line_item['NetWeight'].to_d
#        extended_amount_total = extended_amount_total + line_item['ExtendedAmount'].to_d
        
#        ticket_number = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["TicketNumber"]
#        company_name = tickets_array.find {|ticket| ticket['Id'] == line_item["TicketHeadId"]}["Company"]
#        customer_name = "#{tickets_array.find {|ticket| ticket['Id'] == line_item['TicketHeadId']}['FirstName']} #{tickets_array.find {|ticket| ticket['Id'] == line_item['TicketHeadId']}['LastName']}"
        
#        csv << headers.map{ |attr| (attr == 'Ticket' ? ticket_number : (attr == 'Customer' ? (company_name.blank? ? customer_name : company_name) : line_item[attr]) ) }
#          csv << [date_created, description, ticket_number, job_number, bol_number, purchase_order_number, name, customer_number, customer_ship_date, 
#            print_description, gross_weight, tare_weight, net_weight, price, extended_amount]
         csv << [date_created, print_description, ticket_number, name, status, gross_weight, tare_weight, net_weight, price, extended_amount]
      end
#      csv << ['', '', '', '', '', '', '', '', '', '', '', '', net_total, '', extended_amount_total]
    end
  end
  
  def self.v2_commodity_summary_to_csv(line_items_array)
    require 'csv'
    headers = ['DateCreated', 'Commodity', 'Ticket', 'Customer', 'Status', 'GrossWeight', 'TareWeight', 'NetWeight', 'Price', 'ExtendedAmount']
    
    CSV.generate(headers: true) do |csv|
      csv << headers
      line_items_array.each do |line_item|
        date_created = line_item.date_created
        ticket_number = line_item.ticket_head.ticket_number
        customer_name = "#{line_item.ticket_head.customer.first_name} #{line_item.ticket_head.customer.last_name}"
        company_name = line_item.ticket_head.customer.company
        name = company_name.blank? ? customer_name : company_name
        print_description = line_item.print_description
        status = line_item.ticket_head.ticket_status
        gross_weight = line_item.gross_weight
        tare_weight = line_item.tare_weight
        net_weight = line_item.net_weight
        price = "#{line_item.price} #{line_item.unit_of_measure}"
        extended_amount = line_item.extended_amount
        csv << [date_created, print_description, ticket_number, name, status, gross_weight, tare_weight, net_weight, price, extended_amount]
      end
    end
  end
  
  def self.vin_search(auth_token, vin)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/vehicle/vindecode?vin=#{vin}"
    begin
      xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
          :content_type => 'application/json', :Accept => "application/xml"})
      data= Hash.from_xml(xml_content)
#      Rails.logger.info "Ticket.vin_search response: #{data}"
      if not data["GetVehicleIdentificationDecodeResponse"].blank? and data["GetVehicleIdentificationDecodeResponse"]["Success"] == 'true'
        unless data["GetVehicleIdentificationDecodeResponse"]["DecodedVehicleIdentificationNumber"].blank?
          return data["GetVehicleIdentificationDecodeResponse"]["DecodedVehicleIdentificationNumber"]
        else
          return nil
        end
      else
        return nil
      end
    rescue RestClient::ExceptionWithResponse => e
#      Rails.logger.info "Ticket.vin_search call: no Dragon API"
      return nil
    end
  end
  
  def self.status_string(status)
    if status == "1"
      return "Closed"
    elsif status == "2"
      return "Held"
    elsif status == "3"
      return "Paid"
    else
      "N/A"
    end
  end
  
  def self.average_wait_time(tickets_array)
    tickets = tickets_array
    unless tickets.blank?
      minutes_sum = 0
      count = tickets.count
      tickets.each do |ticket|
        created = ticket['DateCreated'].blank? ? nil : ticket['DateCreated'].to_datetime
        closed = ticket['DateClosed'].blank? ? nil : ticket['DateClosed'].to_datetime
        unless (created.blank? or closed.blank?) or (created > closed) or (created.beginning_of_day != closed.beginning_of_day)
          difference = closed.to_i - created.to_i
          
          minutes = (difference / 60)
          minutes_sum += minutes
        end
      end
      return (minutes_sum / count).round
    else
      return 0
    end
  end
  
  def self.deductions(auth_token)
    access_token = AccessToken.where(token_string: auth_token).last # Find access token record
    user = access_token.user # Get access token's user record
    api_url = "https://#{user.company.dragon_api}/api/udl/7"
    begin
      xml_content = RestClient::Request.execute(method: :get, url: api_url, verify_ssl: false, headers: {:Authorization => "Bearer #{auth_token}", 
          :content_type => 'application/json', :Accept => "application/xml"})
      data= Hash.from_xml(xml_content)
#      Rails.logger.info "*********************Ticket.deductions response: #{data}"
      if not data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"].blank? and data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Success"] == 'true'
        unless data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Items"].blank? or data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Items"]["ApiUserDefinedListValue"].blank?
          return data["ApiItemsResponseOfApiUserDefinedListValueSoP0f0Yh"]["Items"]["ApiUserDefinedListValue"]
        else
          return []
        end
      else
        return []
      end
    rescue RestClient::ExceptionWithResponse => e
#      Rails.logger.info "Ticket.deductions call: no Dragon API"
      return nil
    end
  end
  
  def self.deductions_grouped_for_select(deductions)
    deductions.collect { |d| d['CodeValue'] }
  end
  
end