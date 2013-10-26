class MigrateAnimeAndMangaDescriptionToDescriptionHtml < ActiveRecord::Migration
  def self.up
    Anime.connection.execute("update animes set description_html=description where description != ''")
    Manga.connection.execute("update mangas set description_html=description where description != ''")
  end

  def self.down
  end
end
