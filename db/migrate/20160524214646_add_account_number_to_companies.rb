class AddAccountNumberToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :account_number, :string
  end
end
