class FillTypeInMangas < ActiveRecord::Migration[5.0]
  def change
    Manga.where(kind: 'novel').update_all type: 'Ranobe'
    Manga.where.not(kind: 'novel').update_all type: 'Manga'
  end
end
