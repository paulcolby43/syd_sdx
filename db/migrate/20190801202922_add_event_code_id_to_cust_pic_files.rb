class AddEventCodeIdToCustPicFiles < ActiveRecord::Migration
  def change
    add_column :cust_pic_files, :event_code_id, :integer
  end
end
