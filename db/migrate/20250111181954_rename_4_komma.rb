class Rename4Komma < ActiveRecord::Migration[7.1]
  def change
    Anime.where(origin: '4-koma_manga').update_all(origin: 'four_koma_manga')
  end
end
