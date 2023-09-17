class SetupGenreV2Positions < ActiveRecord::Migration[7.0]
  def change
    GenreV2.all.select(&:demographic?).each { |v| v.update! position: 10 }
    GenreV2.all.select(&:genre?).each { |v| v.update! position: 100 }
    GenreV2.all.select(&:theme?).each { |v| v.update! position: 1000 }
  end
end
