class MakeLicensorNotNullInAnimes < ActiveRecord::Migration[5.2]
  def up
    change_column_default :animes, :russian, from: nil, to: ''
    change_column_default :mangas, :russian, from: nil, to: ''

    Anime.where(russian: nil).update_all russian: ''
    Manga.where(russian: nil).update_all russian: ''

    change_column :animes, :russian, :string, null: false
    change_column :mangas, :russian, :string, null: false
  end

  def down
    change_column_default :animes, :russian, from: '', to: false
    change_column_default :mangas, :russian, from: '', to: false

    change_column :animes, :russian, :string, null: true
    change_column :mangas, :russian, :string, null: true
  end
end
