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
    ["Gross", "Tare", "Deduction", "License Plate", "Title", "VIN", "Signature", "Vehicle", "Customer", "Other"]
  end
  
  def shipment_event_codes
    ["On ground", "Empty inside #", "Empty outside #", "Half loaded", "Fully loaded", "Full - outside #", "Sealed", "Seal close-up", "Other"]
  end
  
  def cust_pic_event_codes
    ["Photo ID", "Customer Photo", "Certificate", "Finger Print", "Vehicle"]
  end
  
  def units_of_measure
    [['Each', 'EA'], ['Pound', 'LB'], ['Net Ton', 'NT'], ['Short Ton', 'ST'], ['Gross Ton', 'GT'], ['Kilogram', 'KG'], ['Hundred Weight', 'CW'], ['Metric Ton', 'MT'], ['Load', 'LD']]
  end
  
  def units_of_measure_abbreviations
    ['EA', 'LB', 'NT', 'ST', 'GT', 'KG', 'CW', 'MT', 'LD']
  end
  
  def units_of_measure_hash
    Hash[units_of_measure]
  end
  
  def ticket_status_string(status_number)
    status_hash = {"1" => "Closed", "2" => "Held", "3" => "Paid"}
    return status_hash[status_number]
  end
  
  def payment_method_string(method_number)
    method_hash = {"0" => "Cash", "1" => "Check", "3" => "EZcash", "4" => "Unknown"}
    return method_hash[method_number]
  end
  
  def shipment_status_string(status_number)
    status_hash = {"1" => "Held", "0" => "Closed"}
    return status_hash[status_number]
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

  def us_states_and_ca_provinces
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
      ['Wyoming', 'WY'],
      ["Alberta", "AB"],
      ["British Columbia", "BC"],
      ["Manitoba", "MB"],
      ["New Brunswick", "NB"],
      ["Newfoundland and Labrador", "NL"],
      ["Nova Scotia", "NS"],
      ["Northwest Territories", "NT"],
      ["Nunavut", "NU"],
      ["Ontario", "ON"],
      ["Prince Edward Island", "PE"],
      ["Quebec", "QC"],
      ["Saskatchewan", "SK"],
      ["Yukon", "YT"]
    ]
end

  def pack_status_description(status)
    if status == '0'
      return "Closed"
    elsif status == '1'
      return "Void"
    elsif status == '2'
      return "Held"
    elsif status == '3'
      return "Manifest"
    elsif status == '4'
      return "Shipped"
    elsif status == '5'
      return "Transferred"
    else
      return "Unknown Status"
    end
  end
 
  def camera_classes
    [['Article Image', 'A'], ['Customer image', 'C'], ['Customer ID image', 'I'], ['Customer thumbprint image', 'T'], ['Customer signature', 'S'], ['Vehicle image', 'V'], ['Do not send image', 'N'], ['Document', 'D']]
  end
  
  def camera_positions
    [['Directly above', 'A'], ['From behind', 'B'], ['From left/driver side', 'D'], ['From front', 'F'], ['Not supplied or not applicable', 'N'], ['Right/passenger side', 'P'], ['Unspecified side', 'S']]
  end
  
  def camera_class_string(camera_class)
    camera_class_hash = {'A' => 'Article Image', 'C' => 'Customer image', 'I' => 'Customer ID image', 'T' => 'Customer thumbprint image', 'S' => 'Customer signature', 'V' => 'Vehicle image', 'N' => 'Do not send image', 'D' => 'Document'}
    return camera_class_hash[camera_class]
  end
  
  def camera_position_string(camera_position)
    camera_position_hash = {'A' => 'Directly above', 'B' => 'From behind', 'D' => 'From left/driver side', 'F' => 'From front', 'N' => 'Not supplied or not applicable', 'P' => 'Right/passenger side', 'S' => 'Unspecified side'}
    return camera_position_hash[camera_position]
  end
  
  require 'open-uri'
  def embed_remote_image(url, content_type)
    asset = open(url, "r:UTF-8") { |f| f.read }
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{content_type};base64,#{Rack::Utils.escape(base64)}"
  end

end