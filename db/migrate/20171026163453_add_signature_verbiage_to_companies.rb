class AddSignatureVerbiageToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :signature_verbiage, :text
  end
end
