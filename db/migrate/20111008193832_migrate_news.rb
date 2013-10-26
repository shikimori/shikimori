class MigrateNews < ActiveRecord::Migration
  def self.up
    Entry.record_timestamps = false
    Topic.record_timestamps = false
    AnimeNews.record_timestamps = false
    Message.record_timestamps = false

    # site news migration
    Entry.where(:section_id => 6).includes(:comment_threads).all.each do |topic|
      topic.type = Topic.name
      topic.processed = true
      topic.text = topic.comment_threads.last.body
      topic.section_id = 4

      topic.save
      topic.comment_threads.last.destroy
    end
    print "site news migration finished\n"

    messages = Message.where('anime_history_id is not null').all.group_by {|v| v.anime_history_id }

    Entry.where(:section_id => 2).where('anime_history_id is not null').includes(:comment_threads).all.each do |topic|
      history = topic.anime_history

      topic.type = AnimeNews.name
      topic.processed = history.processed
      topic.action = history.action
      topic.linked_id = history.anime_id
      topic.linked_type = Anime.name
      topic.value = history.value
      topic.section_id = 1
      topic.text = topic.comment_threads.last.body.gsub(/\[\/?poster\]|\[url=[^\]]+\]\[img class=image-poster\].*$|#info/, '').gsub(/\n ?/, ' ')
      topic.processed = history.processed

      topic.save
      topic.comment_threads.last.destroy

      if messages.include?(history.id)
        messages[history.id].each do |v|
          v.update_attribute(:anime_history_id, topic.id)
        end
      end
    end
    Message.where('body is not null').all.each do |v|
      v.update_attribute(:body, v.body.gsub(/\[\/?poster\]|\[url=[^\]]+\]\[img class=image-poster\].*$|#info/, '').gsub(/\n ?/, ' '))
    end
    AnimeHistory.includes(:anime).where(:action => 'episode').each do |history|
      entry = AnimeNews.create(:in_forum => false,
                               :created_at => history.created_at,
                               :updated_at => history.created_at,
                               :processed => history.processed,
                               :action => history.action,
                               :linked_id => history.anime_id,
                               :value => history.value,
                               :section_id => 1,
                               :linked_type => Anime.name)

      if messages.include?(history.id)
        messages[history.id].each do |v|
          v.update_attribute(:anime_history_id, entry.id)
        end
      end
    end
    print "anime news migration finished\n"

    Section.find(2).destroy
    Section.find(6).destroy

    remove_column :entries, :anime_history_id
  end

  def self.down
    add_column :entries, :anime_history_id, :integer
  end
end
