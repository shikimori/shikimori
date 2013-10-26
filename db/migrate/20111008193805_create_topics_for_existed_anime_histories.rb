class CreateTopicsForExistedAnimeHistories < ActiveRecord::Migration
  def self.up
    AnimeHistory.where("action != 'new_episode'").
                 includes(:anime).
                 all.
                   each do |entry|
      entry.create_topic
      entry.topic.update_attribute(:updated_at, entry.created_at)
    end
  end

  def self.down
    Topic.where('anime_history_id != 0').destroy_all
    AnimeHistory.where('topic_id != 0').all.each {|v| v.update_attribute(:topic_id, 0) }
  end
end
