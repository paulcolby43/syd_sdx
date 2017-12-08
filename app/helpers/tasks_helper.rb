module TasksHelper
  def task_status_string(status_number)
    status_hash = {"0" => "In Queue", "1" => "Started", "2" => "Completed", "3" => "Void", "4" => "Delayed"}
    return status_hash[status_number]
  end
end