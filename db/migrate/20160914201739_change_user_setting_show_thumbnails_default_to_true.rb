class ChangeUserSettingShowThumbnailsDefaultToTrue < ActiveRecord::Migration
  def change
    change_column :user_settings, :show_thumbnails, :boolean, :default => true
  end
end
