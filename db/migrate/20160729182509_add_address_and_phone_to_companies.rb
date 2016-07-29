class AddAddressAndPhoneToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :address1, :string
    add_column :companies, :address2, :string
    add_column :companies, :city, :string
    add_column :companies, :state, :string
    add_column :companies, :zip, :string
    add_column :companies, :phone, :string
  end
end
