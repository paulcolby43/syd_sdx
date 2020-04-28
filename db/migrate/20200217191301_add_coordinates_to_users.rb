class AddCoordinatesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :coordinates, :text
  end
end
