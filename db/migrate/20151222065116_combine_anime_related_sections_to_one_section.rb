class CombineAnimeRelatedSectionsToOneSection < ActiveRecord::Migration
  def up
    Entry.where(forum_id: [6, 7, 14]).update_all forum_id: 1
    Forum.where(id: [6, 7, 14]).destroy_all
    Forum.find(1).update(
      name: 'Аниме и манга',
      permalink: 'animanga',
      is_visible: true
    )
    Forum.find(17).update position: 5
    Forum.find(16).update position: 6
    Forum.find(4).update position: 7, permalink: 'site'
    Forum.find(8).update position: 8, permalink: 'offtopic'
    Forum.find(10).update permalink: 'clubs'
    Forum.find(13).update permalink: 'contests'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
