class AddDragonAccountNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dragon_account_number, :string
  end
end
