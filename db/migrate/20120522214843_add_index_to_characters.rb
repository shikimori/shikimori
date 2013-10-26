class AddIndexToCharacters < ActiveRecord::Migration
  def self.up
    # индексы для работы поиска
    add_index :characters, :russian, :length => 50
    add_index :characters, :japanese
    add_index :characters, :name
  end

  def self.down
    remove_index :characters, :name
    remove_index :characters, :russian
    remove_index :characters, :japanese
  end
end
