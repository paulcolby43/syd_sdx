class AddYardIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :yard_id, :string
  end
end
