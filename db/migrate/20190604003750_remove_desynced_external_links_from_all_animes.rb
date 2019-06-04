class RemoveDesyncedExternalLinksFromAllAnimes < ActiveRecord::Migration[5.2]
  def up
    Anime.where("'external_links' = ANY(desynced)").find_each do |anime|
      anime.desynced -= %w[external_links]
      anime.save
    end
  end
end
