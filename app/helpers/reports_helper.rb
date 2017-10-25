module ReportsHelper
  
  def ticket_commodity_weight_donut_data(line_items)
    line_items.group_by{ |i| i['PrintDescription'] }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i['NetWeight'].to_d }.sum.round }
    end
  end
  
  def ticket_commodity_amount_donut_data(line_items)
    line_items.group_by{ |i| i['PrintDescription'] }.map do |(line_item_group, line_items)|
      {label: line_item_group, value: line_items.map { |i| i['ExtendedAmount'].to_d }.sum.round }
    end
  end
  
end