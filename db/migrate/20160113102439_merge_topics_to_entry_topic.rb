class MergeTopicsToEntryTopic < ActiveRecord::Migration
  def up
    Entry
      .where(type: ['AniMangaComment', 'CharacterComment', 'PersonComment'])
      .update_all(type: 'Topics::EntryTopic', title: nil, body: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
