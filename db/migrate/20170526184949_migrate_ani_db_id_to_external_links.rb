class MigrateAniDbIdToExternalLinks < ActiveRecord::Migration[5.0]
  def up
     Anime
      .where.not(ani_db_id: [nil, 0])
      .includes(:external_links)
      .select { |v| v.external_links.none?(&:kind_anime_db?) }
      .each do |anime|
        anime.external_links.create!(
          kind: :anime_db,
          url: "http://anidb.net/perl-bin/animedb.pl?show=anime&aid=#{anime.ani_db_id}",
          source: :shikimori
        )
      end
  end

  def down
    ExternalLink.where(kind: :anime_db, source: :shikimori).delete_all
  end
end
