class AddEmailedToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :emailed, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :emailed
  end
end
