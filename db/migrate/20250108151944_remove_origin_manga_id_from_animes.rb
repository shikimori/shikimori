class RemoveOriginMangaIdFromAnimes < ActiveRecord::Migration[7.1]
  def change
    remove_column :animes, :origin_manga_id, :bigint
  end
end
