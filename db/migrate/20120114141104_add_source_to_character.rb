class AddSourceToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :source, :string
  end

  def self.down
    remove_column :characters, :source
  end
end
