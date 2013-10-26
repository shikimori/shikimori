class AddToAnimeHistoryIdToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :anime_history_id, :integer
  end

  def self.down
    remove_column :topics, :anime_history_id
  end
end
