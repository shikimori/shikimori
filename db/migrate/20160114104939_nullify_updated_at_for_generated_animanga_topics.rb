class NullifyUpdatedAtForGeneratedAnimangaTopics < ActiveRecord::Migration
  def change
    Entry
      .where(type: [
        Topics::EntryTopics::AnimeTopic.name,
        Topics::EntryTopics::MangaTopic.name,
        Topics::EntryTopics::CharacterTopic.name,
        Topics::EntryTopics::PersonTopi.namec
      ])
      .where(comments_count: 0)
      .where(generated: true)
      .update_all updated_at: nil
  end
end
