class AddTicketsShipmentsDispatchToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tickets, :boolean, :default => true
    add_column :users, :shipments, :boolean, :default => true
    add_column :users, :dispatch, :boolean, :default => true
  end
end
