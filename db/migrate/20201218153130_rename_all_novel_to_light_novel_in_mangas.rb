class RenameAllNovelToLightNovelInMangas < ActiveRecord::Migration[5.2]
  def change
    Manga.where(kind: 'novel').update_all kind: 'light_novel'
  end
end
