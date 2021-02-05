module TasksHelper
  
  def task_status_string(status_number)
    status_hash = {"0" => "InQueue", "1" => "Started", "2" => "Completed", "3" => "Void", "4" => "Delayed"}
    return status_hash[status_number]
  end
  
  def task_type_string(type_number)
    type_hash = {"0" => "Pickup Container", "1" => "Dropoff Container", "2" => "No Container", "3" => "Dump Container", "4" => "Empty Container", "5" => "Cross State Lines"}
    return type_hash[type_number]
  end
  
  def task_type_abbreviated_string(type_number)
    type_hash = {"0" => "Pickup", "1" => "Dropoff", "2" => "None", "3" => "Dump", "4" => "Empty", "5" => "Cross"}
    return type_hash[type_number]
  end
  
  def task_status_array
    [["InQueue", "0"], ["Started", "1"], ["Completed", "2"], ["Void", "3"], ["Delayed", "4"]]
  end
  
  def task_status_array_without_completed
    [["InQueue", "0"], ["Started", "1"], ["Void", "3"], ["Delayed", "4"]]
  end
  
  def v2_task_status_array
    [["InQueue", "INQUEUE"], ["Started", "STARTED"], ["Completed", "COMPLETED"], ["Void", "VOID"], ["Delayed", "DELAYED"]]
  end
  
  def v2_task_status_array_without_completed
    [["InQueue", "INQUEUE"], ["Started", "STARTED"], ["Void", "VOID"], ["Delayed", "DELAYED"]]
  end
  
  def task_status_color(status)
#    White: InQueue (0)
#    Yellow: Started (1)
#    Green: Completed (2)
#    Red: Void (3)
#    Gray(blue): Delayed (4)
#    
    task_status_color_hash = {'0' => 'list-group-item', '1' => 'list-group-item-warning', '2' => 'list-group-item-success', '3' => 'list-group-item-danger', '4' => 'list-group-item-info'}
    return task_status_color_hash[status]
  end
  
  def v2_task_status_color(status)
#    White: InQueue (0)
#    Yellow: Started (1)
#    Green: Completed (2)
#    Red: Void (3)
#    Gray(blue): Delayed (4)
#    
    task_status_color_hash = {'IN_QUEUE' => 'list-group-item', 'STARTED' => 'list-group-item-warning', 'COMPLETED' => 'list-group-item-success', 'VOID' => 'list-group-item-danger', 'DELAYED' => 'list-group-item-info'}
    return task_status_color_hash[status]
  end
  
end