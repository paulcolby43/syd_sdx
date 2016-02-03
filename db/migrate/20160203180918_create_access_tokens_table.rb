class CreateAccessTokensTable < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string :token_string
      t.integer :user_id
      t.datetime :expiration
      
      t.timestamps
    end
  end
end
