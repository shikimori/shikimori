class AddImportedToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :imported_at, :datetime
  end

  def self.down
    remove_column :animes, :imported_at
  end
end
