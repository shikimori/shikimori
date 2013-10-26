class RenamePageUrlToPermalink < ActiveRecord::Migration
  def self.up
    rename_column :pages, :url, :permalink
  end

  def self.down
    rename_column :pages, :permalink, :url
  end
end
