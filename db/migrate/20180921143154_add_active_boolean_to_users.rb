class AddActiveBooleanToUsers < ActiveRecord::Migration
  def change
#    add_column :users, :active, :boolean, default: true
    change_table :tags do |t|
    # t.boolean :active, default: true
    end
  end
end
