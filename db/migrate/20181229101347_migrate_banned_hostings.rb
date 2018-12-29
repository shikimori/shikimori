class MigrateBannedHostings < ActiveRecord::Migration[5.2]
  def up
    AnimeVideo
      .connection
      .execute("update anime_videos set url=REPLACE(url, 'smotret-anime.ru', 'smotretanime.ru') where url like '%kadu.ru%'").to_a
    AnimeVideo
      .connection
      .execute("update anime_videos set url=REPLACE(url, 'kadu.ru', 'gidfilm.ru') where url like '%kadu.ru%'").to_a
  end

  def down
    AnimeVideo
      .connection
      .execute("update anime_videos set url=REPLACE(url, 'smotretanime.ru', 'smotret-anime.ru') where url like '%kadu.ru%'").to_a
    AnimeVideo
      .connection
      .execute("update anime_videos set url=REPLACE(url, 'gidfilm.ru', 'kadu.ru') where url like '%kadu.ru%'").to_a
  end
end
