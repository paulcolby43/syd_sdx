class AddPositionToEventCodes < ActiveRecord::Migration
  def change
    add_column :event_codes, :position, :integer
    
    Company.all.each do |company|
      company.event_codes.order(:name).each.with_index(1) do |event_code, index|
        event_code.update_column :position, index
      end
    end
  end
end
