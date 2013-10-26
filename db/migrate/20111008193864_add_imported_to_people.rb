class AddImportedToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :imported_at, :datetime
  end

  def self.down
    remove_column :people, :imported_at
  end
end
