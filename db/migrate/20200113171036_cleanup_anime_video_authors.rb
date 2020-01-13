class CleanupAnimeVideoAuthors < ActiveRecord::Migration[5.2]
  def change
    AnimeVideoAuthor.delete_all
  end
end
