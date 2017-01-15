class AddIdToAnimesStudios < ActiveRecord::Migration
  def change
    add_column :animes_studios, :id, :primary_key
  end
end
