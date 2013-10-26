class AddComplexIndexToMessages < ActiveRecord::Migration
  def self.up
    add_index :messages, [:src_type, :dst_type, :src_id, :src_del, :kind], name: :private_and_notifications
  end

  def self.down
    remove_index :messages, name: :private_and_notifications
  end
end
