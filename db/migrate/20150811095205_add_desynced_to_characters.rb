class AddDesyncedToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :desynced, :text, null: false, default: [], array: true
    add_column :people, :desynced, :text, null: false, default: [], array: true
  end
end
