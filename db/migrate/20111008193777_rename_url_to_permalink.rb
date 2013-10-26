class RenameUrlToPermalink < ActiveRecord::Migration
  def self.up
    rename_column :topics, :url, :permalink
    rename_column :sections, :url, :permalink
  end

  def self.down
    rename_column :topics, :permalink, :url
    rename_column :sections, :permalink, :url
  end
end
