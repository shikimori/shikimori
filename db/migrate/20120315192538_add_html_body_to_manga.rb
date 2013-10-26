class AddHtmlBodyToManga < ActiveRecord::Migration
  def self.up
    add_column :mangas, :description_html, :text
  end

  def self.down
    remove_column :mangas, :description_html
  end
end
