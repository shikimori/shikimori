class MakeLicensorNotNullInAnimes < ActiveRecord::Migration[5.2]
  def up
    change_column_default :animes, :licensor, from: nil, to: ''
    change_column_default :mangas, :licensor, from: nil, to: ''

    Anime.where(licensor: nil).update_all licensor: ''
    Manga.where(licensor: nil).update_all licensor: ''

    change_column :animes, :licensor, :string, null: false
    change_column :mangas, :licensor, :string, null: false
  end

  def down
    change_column_default :animes, :licensor, from: '', to: false
    change_column_default :mangas, :licensor, from: '', to: false

    change_column :animes, :licensor, :string, null: true
    change_column :mangas, :licensor, :string, null: true
  end
end
