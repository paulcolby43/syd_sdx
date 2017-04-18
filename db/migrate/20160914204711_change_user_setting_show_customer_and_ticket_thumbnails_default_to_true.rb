class ChangeUserSettingShowCustomerAndTicketThumbnailsDefaultToTrue < ActiveRecord::Migration
  def change
    change_column :user_settings, :show_customer_thumbnails, :boolean, :default => true
    change_column :user_settings, :show_ticket_thumbnails, :boolean, :default => true
  end
end
