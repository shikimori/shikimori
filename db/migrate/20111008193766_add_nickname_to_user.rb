class AddNicknameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :nickname, :string
  end

  def self.down
    remove_column :users, :nickname
  end
end
