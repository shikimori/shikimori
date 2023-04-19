class ActualizeGenresEntryTypeValues < ActiveRecord::Migration[6.1]
  def up
    Genre.where(entry_type: 'anime').update_all entry_type: 'Anime'
    Genre.where(entry_type: 'manga').update_all entry_type: 'Manga'
  end

  def down
    Genre.where(entry_type: 'Anime').update_all entry_type: 'anime'
    Genre.where(entry_type: 'Manga').update_all entry_type: 'manga'
  end
end
