class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_access_token, :string
    add_index :users, :api_access_token
  end
end
