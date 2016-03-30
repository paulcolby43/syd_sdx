class AddContractVerbiageToImageFiles < ActiveRecord::Migration
  def change
    add_column :image_files, :contract_verbiage, :string
  end
end
