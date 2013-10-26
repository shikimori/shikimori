class AddImportedToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :imported_at, :datetime
  end

  def self.down
    remove_column :characters, :imported_at
  end
end
