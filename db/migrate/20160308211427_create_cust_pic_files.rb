class CreateCustPicFiles < ActiveRecord::Migration
  def change
    create_table :cust_pic_files do |t|
      t.string :name
      t.string :file
      t.integer :user_id
      t.string :customer_number
      t.string :location
      t.string :event_code
      t.integer :cust_pic_id
      t.boolean :hidden, :default => false
      t.integer :blob_id
      t.string :vin_number
      t.string :tag_number

      t.timestamps
    end
  end
end
