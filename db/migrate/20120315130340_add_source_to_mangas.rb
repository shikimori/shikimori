class AddSourceToMangas < ActiveRecord::Migration
  def self.up
    add_column :mangas, :source, :string
  end

  def self.down
    remove_column :mangas, :source
  end
end
