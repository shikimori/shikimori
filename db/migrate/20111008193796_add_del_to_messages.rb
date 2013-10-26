class AddDelToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :src_del, :boolean, :default => false
    add_column :messages, :dst_del, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :dst_del
    remove_column :messages, :src_del
  end
end
