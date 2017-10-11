class AddIncludeShipmentsInventoriesExternalUsersToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :include_shipments, :boolean, default: false
    add_column :companies, :include_inventories, :boolean, default: false
    add_column :companies, :include_external_users, :boolean, default: false
  end
end
