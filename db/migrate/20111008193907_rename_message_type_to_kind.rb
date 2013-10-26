class RenameMessageTypeToKind < ActiveRecord::Migration
  def self.up
    rename_column :messages, :message_type, :kind
  end

  def self.down
    rename_column :messages, :kind, :message_type
  end
end
