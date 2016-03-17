class AddYardIdToImageFilesAndCustPicFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :yard_id, :string
    add_column :cust_pic_files, :yard_id, :string
  end
end
