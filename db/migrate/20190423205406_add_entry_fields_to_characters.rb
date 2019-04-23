class AddEntryFieldsToCharacters < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :is_anime, :boolean, null: false, default: false
    add_column :characters, :is_manga, :boolean, null: false, default: false
    add_column :characters, :is_ranobe, :boolean, null: false, default: false
  end
end
