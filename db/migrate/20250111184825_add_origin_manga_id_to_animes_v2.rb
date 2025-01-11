class AddOriginMangaIdToAnimesV2 < ActiveRecord::Migration[7.1]
  def change
    add_reference :animes, :origin_manga,
      null: true,
      foreign_key: { to_table: :mangas },
      index: true
  end
end
