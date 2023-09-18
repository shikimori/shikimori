class SetupGenreV2Positions < ActiveRecord::Migration[7.0]
  def up
    GenreV2.where(name: 'Shounen').update_all position: 10
    GenreV2.where(name: 'Shoujo').update_all position: 11
    GenreV2.where(name: 'Seinen').update_all position: 12
    GenreV2.where(name: 'Josei').update_all position: 13
    GenreV2.where(name: 'Kids').update_all position: 14
    GenreV2.all.select(&:genre?).each { |v| v.update! position: 100 }
    GenreV2.all.select(&:theme?).each { |v| v.update! position: 1000 }
  end
end
