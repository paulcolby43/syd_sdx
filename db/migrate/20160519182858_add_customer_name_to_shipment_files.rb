class AddCustomerNameToShipmentFiles < ActiveRecord::Migration
  def change
    add_column :shipment_files, :customer_name, :string
  end
end
