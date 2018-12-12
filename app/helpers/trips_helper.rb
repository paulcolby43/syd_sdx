module TripsHelper
  
  def trip_status_string(status_number)
    status_hash = {"0" => "Planned", "1" => "Started", "2" => "Completed", "3" => "Canceled", "4" => "Rescheduled", "5" => "Deployed", "6" => "Merged"}
    return status_hash[status_number]
  end
  
  def trip_status_array
    [["InQueue", "0"], ["Started", "1"], ["Completed", "2"], ["Void", "3"], ["Delayed", "4"]]
  end
  
  def trip_status_color(status)
    trip_status_color_hash = {'0' => '', '1' => 'list-group-item-warning', '2' => 'list-group-item-success', '3' => 'list-group-item-danger', '4' => 'list-group-item-info'}
    return trip_status_color_hash[status]
  end
  
end