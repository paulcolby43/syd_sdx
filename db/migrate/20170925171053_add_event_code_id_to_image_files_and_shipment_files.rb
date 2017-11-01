class AddEventCodeIdToImageFilesAndShipmentFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :event_code_id, :integer
    add_column :shipment_files, :event_code_id, :integer
  end
end
