class AddNotNullToMessagesRead < ActiveRecord::Migration
  def self.up
    change_column :messages, :read, :boolean, :null => false, :default => false
  end

  def self.down
  end
end
