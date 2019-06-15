class RemoveUsersApiAccessToken < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :api_access_token, :string
  end
end
