class AddIdToAnimesStudios < ActiveRecord::Migration[5.2]
  def change
    add_column :animes_studios, :id, :primary_key
  end
end
