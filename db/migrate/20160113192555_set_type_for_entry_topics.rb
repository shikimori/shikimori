class SetTypeForEntryTopics < ActiveRecord::Migration
  def change
    Entry.where(type: 'ReviewComment')
      .update_all(type: 'Topics::EntryTopics::ReviewTopic')

    Entry.where(type: 'ContestComment')
      .update_all(type: 'Topics::EntryTopics::ContestTopic')

    Entry.where(type: 'CosplayComment')
      .update_all(type: 'Topics::EntryTopics::CosplayGalleryTopic')

    Entry.where(type: 'ClubComment')
      .update_all(type: 'Topics::EntryTopics::ClubTopic')

    Entry.where(type: 'Topics::EntryTopic', generated: true, linked_type: 'Anime')
      .update_all(type: 'Topics::EntryTopics::AnimeTopic')

    Entry.where(type: 'Topics::EntryTopic', generated: true, linked_type: 'Manga')
      .update_all(type: 'Topics::EntryTopics::MangaTopic')

    Entry.where(type: 'Topics::EntryTopic', generated: true, linked_type: 'Character')
      .update_all(type: 'Topics::EntryTopics::CharacterTopic')

    Entry.where(type: 'Topics::EntryTopic', generated: true, linked_type: 'Person')
      .update_all(type: 'Topics::EntryTopics::PersonTopic')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
