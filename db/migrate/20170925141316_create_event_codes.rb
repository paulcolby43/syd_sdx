class CreateEventCodes < ActiveRecord::Migration
  def change
    create_table :event_codes do |t|
      t.string :name
      t.string :camera_class
      t.string :camera_position
      t.integer :user_id
      t.integer :company_id
      t.boolean :include_in_fetch_lists, default: false
      t.boolean :include_in_shipments, default: true
      t.boolean :include_in_images, default: true

      t.timestamps
    end
  end
end
