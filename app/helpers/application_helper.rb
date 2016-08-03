module ApplicationHelper
  
#  def bootstrap_class_for flash_type
#    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
#  end
# 
#  def flash_messages(opts = {})
#    flash.each do |msg_type, message|
#      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do 
#            concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
#              concat message
#            end) unless msg_type == 'timedout'
#        end
#      nil
#    end
#  
#    end

  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  
  def ticket_event_codes
    ["Gross", "Tare", "Deduction", "License Plate", "Title", "VIN", "Signature", "Vehicle", "Customer"]
  end
  
  def shipment_event_codes
    ["On ground", "Empty inside #", "Empty outside #", "Half loaded", "Fully loaded", "Full - outside #", "Sealed", "Seal close-up"]
  end
  
  def cust_pic_event_codes
    ["Photo ID", "Customer Photo", "Certificate", "Finger Print", "Vehicle"]
  end
  
  def units_of_measure
    [['Each', 'EA'], ['Pound', 'LB'], ['Net Ton', 'NT'], ['Short Ton', 'ST'], ['Gross Ton', 'GT'], ['Kilogram', 'KG'], ['Hundred Weight', 'CW'], ['Metric Ton', 'MT'], ['Load', 'LD']]
  end
  
  def units_of_measure_hash
    Hash[units_of_measure]
  end
  
  def ticket_status_string(status_number)
    status_hash = {"1" => "Closed", "2" => "Held", "3" => "Paid"}
    return status_hash[status_number]
  end
  
  def payment_method_string(method_number)
    method_hash = {"0" => "Cash", "1" => "Check"}
    return method_hash[method_number]
  end
  
  def empty_guid
    '00000000-0000-0000-0000-000000000000'
  end
  
  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
end

end