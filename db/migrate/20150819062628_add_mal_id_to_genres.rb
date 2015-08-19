class AddMalIdToGenres < ActiveRecord::Migration
  def up
    add_column :genres, :mal_id, :integer
    Genre.connection.execute("update genres set mal_id=id")
    change_column :genres, :mal_id, :integer, null: false
  end

  def down
    remove_column :genres, :mal_id, :integer
  end
end
