class MigrateAnimeCommentsToAniMangaComments < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.
      execute("update entries set type='AniMangaComment' where type='AnimeComment'")
  end

  def self.down
    ActiveRecord::Base.connection.
      execute("update entries set type='AnimeComment' where type='AniMangaComment'")
  end
end
