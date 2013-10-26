class AddTagsToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :tags, :string
  end

  def self.down
    remove_column :characters, :tags
  end
end
