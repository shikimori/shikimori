class RemoveDesyncedExternalLinksFromAllAnimes < ActiveRecord::Migration[5.2]
  def up
    Anime.where("'external_links' = ANY(desynced)").find_each do |anime|
      anime.desynced -= %w[external_links]
      anime.save
      MalParsers::FetchEntry.perform_async anime.id, 'anime'
    end
  end
end
