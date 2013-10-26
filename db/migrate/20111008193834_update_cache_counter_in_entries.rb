class UpdateCacheCounterInEntries < ActiveRecord::Migration
  def self.up
    Entry.record_timestamps = false
    Topic.record_timestamps = false
    AnimeNews.record_timestamps = false

    Entry.reset_column_information
    Entry.includes(:comment_threads).all.each do |v|
      v.update_attributes(:comment_threads_count => v.comment_threads.length)
    end
  end

  def self.down
  end
end
