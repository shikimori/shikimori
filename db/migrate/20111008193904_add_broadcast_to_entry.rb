class AddBroadcastToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :broadcast, :boolean, :default => false
  end

  def self.down
    remove_column :entries, :broadcast
  end
end
