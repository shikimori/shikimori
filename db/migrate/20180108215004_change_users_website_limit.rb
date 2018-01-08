class ChangeUsersWebsiteLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :users, :website, :string, limit: 1024
  end

  def down
    change_column :users, :website, :string, limit: 255
  end
end
