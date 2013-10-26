class RenamePublishedAtToAiredAt < ActiveRecord::Migration
  def self.up
    rename_column :mangas, :published_at, :aired_at
  end

  def self.down
    rename_column :mangas, :aired_at, :published_at
  end
end
