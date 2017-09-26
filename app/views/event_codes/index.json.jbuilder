json.array!(@event_codes) do |event_code|
  json.extract! event_code, :id, :name, :camera_class, :camera_position
  json.url event_code_url(event_code, format: :json)
end
