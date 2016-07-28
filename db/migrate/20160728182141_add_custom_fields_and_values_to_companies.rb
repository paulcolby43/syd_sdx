class AddCustomFieldsAndValuesToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :custom_field_1, :string
    add_column :companies, :custom_field_1_value, :string
    add_column :companies, :custom_field_2, :string
    add_column :companies, :custom_field_2_value, :string
  end
end
