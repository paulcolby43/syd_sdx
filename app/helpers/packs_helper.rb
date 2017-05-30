module PacksHelper
  def pack_status_string(status_number)
    status_hash = {"0" => "Closed", "1" => "Void", "2" => "Held", "3" => "Manifest", "4" => "Shipped", "5" => "Transferred"}
    return status_hash[status_number]
  end
end