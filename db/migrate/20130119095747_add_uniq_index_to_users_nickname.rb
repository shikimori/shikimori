class AddUniqIndexToUsersNickname < ActiveRecord::Migration
  def self.up
    remove_index :users, :nickname
    add_index :users, :nickname, :unique => true
  end

  def self.down
    remove_index :users, :nickname
    add_index :users, :nickname
  end
end
