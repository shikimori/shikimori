class AddLastOnlineToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_online_at, :datetime
  end

  def self.down
    remove_column :users, :last_online_at
  end
end
