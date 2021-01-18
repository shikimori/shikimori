class AddRateAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rate_at, :datetime
  end
end
