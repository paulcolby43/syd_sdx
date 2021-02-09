module ReportsHelper
  
  def ticket_commodity_weight_donut_data(line_items)
    line_items.group_by{ |i| i['PrintDescription'] }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i['NetWeight'].to_d }.sum.round }
    end
  end
  
  def v2_ticket_commodity_weight_donut_data(line_items)
    line_items.group_by{ |i| i.print_description }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i.net_weight.to_d }.sum.round }
    end
  end
  
  def ticket_commodity_amount_donut_data(line_items)
    line_items.group_by{ |i| i['PrintDescription'] }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i['ExtendedAmount'].to_d }.sum.round }
    end
  end
  
  def v2_ticket_commodity_amount_donut_data(line_items)
    line_items.group_by{ |i| i.print_description }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i.extended_amount.to_d }.sum.round }
    end
  end
  
  def ticket_customer_number_donut_data(tickets)
    tickets.group_by{ |t| "#{t['FirstName']} #{t['LastName']}" }.map do |(ticket_group, tickets)|
      {label: ticket_group, value: tickets.count }
    end
  end
  
  def ticket_customer_amount_donut_data(tickets)
    tickets.group_by{ |t| "#{t['FirstName']} #{t['LastName']}" }.map do |(ticket_group, tickets)|
      {label: ticket_group, value: tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d}.sum.round }
    end
  end
  
end