class AddRolesArrayToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :roles, :text
  end
end
