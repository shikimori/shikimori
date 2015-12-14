class CombineAnimeRelatedSectionsToOneSection < ActiveRecord::Migration
  def up
    Entry.where(section_id: [6, 7, 14]).update_all section_id: 1
    Section.where(id: [6, 7, 14]).destroy_all
    Section.find(1).update(
      name: 'Аниме и манга',
      permalink: 'animanga',
      is_visible: true
    )
    Section.find(17).update position: 5
    Section.find(16).update position: 6
    Section.find(4).update position: 7
    Section.find(8).update position: 8
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
