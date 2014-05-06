class AddIndexesToAnimes < ActiveRecord::Migration
  def change
    add_index :animes, :score
    add_index :animes, :name
    add_index :animes, :russian
  end
end
