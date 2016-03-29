class AddCustomerGuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :customer_guid, :string
  end
end
