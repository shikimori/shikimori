class MigrateWorldArtIdToExternalLinks < ActiveRecord::Migration[5.0]
  def up
    Anime.where.not(world_art_id: nil).order(:id).each do |anime|
      anime.external_links.create!(
        kind: :world_art,
        url: "http://www.world-art.ru/animation/animation.php?id=#{anime.world_art_id}",
        source: :shikimori
      )
    end
  end

  def down
    ExternalLink.where(kind: :world_art).delete_all
  end
end
