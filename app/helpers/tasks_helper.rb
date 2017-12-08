module TasksHelper
  
  def task_status_string(status_number)
    status_hash = {"0" => "In Queue", "1" => "Started", "2" => "Completed", "3" => "Void", "4" => "Delayed"}
    return status_hash[status_number]
  end
  
  def task_type_string(type_number)
    type_hash = {"0" => "Pickup Container", "1" => "Dropoff Container", "2" => "No Container", "3" => "Dump Container", "4" => "Empty Container", "5" => "Cross State Lines"}
    return type_hash[type_number]
  end
  
end