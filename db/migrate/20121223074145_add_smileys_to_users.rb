class AddSmileysToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :smileys, :boolean, default: true
  end

  def self.down
    remove_column :users, :smileys
  end
end
