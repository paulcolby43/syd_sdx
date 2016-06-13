class AddIncludeLeadsOnlineToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :include_leads_online, :boolean, default: true
  end
end
