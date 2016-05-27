class AddCurrencyIdToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :currency_id, :string
  end
end
