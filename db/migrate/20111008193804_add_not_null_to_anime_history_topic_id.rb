class AddNotNullToAnimeHistoryTopicId < ActiveRecord::Migration
  def self.up
    change_column :anime_histories, :topic_id, :integer, :null => false, :default => 0
  end

  def self.down
  end
end
