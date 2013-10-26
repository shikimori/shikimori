class AddIndexToMangas < ActiveRecord::Migration
  def self.up
    add_index :mangas, :kind
  end

  def self.down
    remove_index :mangas, :kind
  end
end
