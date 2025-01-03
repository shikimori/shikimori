class AddOriginMangaIdToAnimes < ActiveRecord::Migration[7.1]
  def change
    add_column :animes, :origin_manga_id, :bigint
  end
end
