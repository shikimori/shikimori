class AddActivityAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :activity_at, :datetime
  end
end
