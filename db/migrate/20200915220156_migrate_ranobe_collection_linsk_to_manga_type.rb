class MigrateRanobeCollectionLinskToMangaType < ActiveRecord::Migration[5.2]
  def change
    CollectionLink
      .where(linked_type: Ranobe.name)
      .update_all(linked_type: Manga.name)
  end
end
