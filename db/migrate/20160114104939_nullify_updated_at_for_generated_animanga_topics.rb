class NullifyUpdatedAtForGeneratedAnimangaTopics < ActiveRecord::Migration
  def change
    Entry
      .where(type: [
        'Topics::EntryTopics::AnimeTopic',
        'Topics::EntryTopics::MangaTopic',
        'Topics::EntryTopics::CharacterTopic',
        'Topics::EntryTopics::PersonTopi'
      ])
      .where(comments_count: 0)
      .where(generated: true)
      .update_all updated_at: nil
  end
end
