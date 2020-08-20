class AddUniqIndexToGenres < ActiveRecord::Migration[5.2]
  def change
    add_index :genres, [:mal_id, :kind], unique: true
  end
end
