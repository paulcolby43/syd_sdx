class AddApiVersionNumberToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :api_supported_versions, :string
  end
end
