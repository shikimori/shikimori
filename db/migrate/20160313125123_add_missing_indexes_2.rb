class AddMissingIndexes2 < ActiveRecord::Migration
  def change
    add_index :club_links, [:club_id, :linked_id, :linked_type]
    add_index :related_animes, :source_id
    add_index :related_mangas, :source_id
  end
end
