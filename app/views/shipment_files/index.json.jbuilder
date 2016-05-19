json.array!(@image_files) do |image_file|
  json.extract! image_file, :id, :name, :file, :user_id, :ticket_number, :customer_number, :branch_code, :location, :event_code, :image_id, :container_number, :booking_number, :contract_number, :hidden, :blob_id
  json.url image_file_url(image_file, format: :json)
end
