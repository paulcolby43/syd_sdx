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
    ["Gross", "Tare", "Deduction", "License Plate", "Title", "VIN", "Signature", "Vehicle", "Vendor"]
  end
  
  def cust_pic_event_codes
    ["Photo ID", "Customer Photo", "Certificate", "Finger Print", "Vehicle"]
  end

end