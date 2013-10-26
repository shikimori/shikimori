class AddUsernameToProvider < ActiveRecord::Migration
  def self.up
    add_column :user_tokens, :nickname, :string
  end

  def self.down
    remove_column :user_tokens, :nickname
  end
end
