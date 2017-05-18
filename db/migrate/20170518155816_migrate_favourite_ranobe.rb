class MigrateFavouriteRanobe < ActiveRecord::Migration[5.0]
  def up
    Favourite
      .joins('left join mangas on mangas.id = linked_id')
      .where(linked_type: 'Manga')
      .where(mangas: { type: 'Ranobe' })
      .update_all linked_type: 'Ranobe'
  end

  def down
    Favourite.where(linked_type: 'Ranobe').update_all linked_type: 'Manga'
  end
end
