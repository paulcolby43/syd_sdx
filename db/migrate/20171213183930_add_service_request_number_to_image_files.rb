class AddServiceRequestNumberToImageFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :service_request_number, :string
  end
end
