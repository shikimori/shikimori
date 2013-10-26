class AddHtmlBodyToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :description_html, :text
  end

  def self.down
    remove_column :animes, :description_html
  end
end
