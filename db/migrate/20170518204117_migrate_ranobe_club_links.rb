class MigrateRanobeClubLinks < ActiveRecord::Migration[5.0]
  def up
    ClubLink
      .joins('left join mangas on mangas.id = linked_id')
      .where(linked_type: 'Manga')
      .where(mangas: { type: 'Ranobe' })
      .update_all linked_type: 'Ranobe'
  end

  def down
    ClubLink.where(linked_type: 'Ranobe').update_all linked_type: 'Manga'
  end
end
