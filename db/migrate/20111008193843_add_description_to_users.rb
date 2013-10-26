class AddDescriptionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :about, :text
  end

  def self.down
    remove_column :users, :about
  end
end
