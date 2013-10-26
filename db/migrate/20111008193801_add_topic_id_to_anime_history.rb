class AddTopicIdToAnimeHistory < ActiveRecord::Migration
  def self.up
    add_column :anime_histories, :topic_id, :integer
  end

  def self.down
    remove_column :anime_histories, :topic_id
  end
end
