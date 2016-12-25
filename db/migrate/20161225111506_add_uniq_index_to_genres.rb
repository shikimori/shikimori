class AddUniqIndexToGenres < ActiveRecord::Migration
  def change
    add_index :genres, [:mal_id, :kind], unique: true
  end
end
