class AddAnimeHistoryIdToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :anime_history_id, :integer
  end

  def self.down
    remove_column :messages, :anime_history_id
  end
end
