class AddDesyncedToAnimes < ActiveRecord::Migration
  def change
    add_column :animes, :desynced, :text, null: false, default: [], array: true
    add_column :mangas, :desynced, :text, null: false, default: [], array: true
  end
end
