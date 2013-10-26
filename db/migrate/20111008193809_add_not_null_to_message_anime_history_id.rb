class AddNotNullToMessageAnimeHistoryId < ActiveRecord::Migration
  def self.up
    change_column :messages, :anime_history_id, :integer, :null => false, :default => 0
  end

  def self.down
  end
end
