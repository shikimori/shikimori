class AddRussianToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :russian, :text
    remove_column :characters, :spoiler
  end

  def self.down
    remove_column :characters, :russian
    add_column :characters, :spoiler, :text
  end
end
