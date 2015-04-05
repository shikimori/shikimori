class AddUniqIndexToApiAccessToken < ActiveRecord::Migration
  def up
    remove_index :users, :api_access_token
    add_index :users, :api_access_token, unique: true
  end

  def down
    remove_index :users, :api_access_token
    add_index :users, :api_access_token
  end
end
