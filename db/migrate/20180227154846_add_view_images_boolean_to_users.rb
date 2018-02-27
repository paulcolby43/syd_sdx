class AddViewImagesBooleanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :view_images, :boolean, default: true
  end
end
