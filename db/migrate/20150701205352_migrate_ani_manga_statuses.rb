class MigrateAniMangaStatuses < ActiveRecord::Migration
  def up
    Anime.connection.execute("update animes set status='anons' where status='Not yet aired'")
    Anime.connection.execute("update animes set status='ongoing' where status='Currently Airing'")
    Anime.connection.execute("update animes set status='released' where status='Finished Airing'")

    Manga.connection.execute("update mangas set status='anons' where status='Not yet published'")
    Manga.connection.execute("update mangas set status='ongoing' where status='Publishing'")
    Manga.connection.execute("update mangas set status='released' where status='Finished'")
    Manga.connection.execute("update mangas set status='released' where status='Finished Airing'")
  end

  def down
    Anime.connection.execute("update animes set status='Not yet aired' where status='anons'")
    Anime.connection.execute("update animes set status='Currently Airing' where status='ongoing'")
    Anime.connection.execute("update animes set status='Finished Airing' where status='released'")

    Manga.connection.execute("update mangas set status='Not yet published' where status='anons'")
    Manga.connection.execute("update mangas set status='Publishing' where status='ongoing'")
    Manga.connection.execute("update mangas set status='Finished' where status='released'")
  end
end
