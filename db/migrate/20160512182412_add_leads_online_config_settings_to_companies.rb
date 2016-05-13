class AddLeadsOnlineConfigSettingsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :leads_online_store_id, :string
    add_column :companies, :leads_online_ftp_username, :string
    add_column :companies, :leads_online_ftp_password, :string
  end
end
