class AddIncludeDispatchToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :include_dispatch, :boolean, default: false
  end
end
