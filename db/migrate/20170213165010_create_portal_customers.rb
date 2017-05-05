class CreatePortalCustomers < ActiveRecord::Migration
  def change
    create_table :portal_customers do |t|
      t.integer :user_id
      t.string :customer_guid
      
      t.timestamps
    end
  end
end
