class AddIndexOnNicknameToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :nickname
  end

  def self.down
    remove_index :users, :nickname
  end
end
