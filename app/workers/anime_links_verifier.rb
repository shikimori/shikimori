class AnimeLinksVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    raise "Ambiguous anime links found: #{bad_entries(FindAnimeImporter::SERVICE).join ', '}" if bad_entries(FindAnimeImporter::SERVICE).any?
    raise "Ambiguous anime links found: #{bad_entries(HentaiAnimeImporter::SERVICE).join ', '}" if bad_entries(HentaiAnimeImporter::SERVICE).any?
  end

  def bad_entries service
    AnimeLink
      .where(service: service)
      .group_by(&:anime_id)
      .select {|k,v| v.size > 1 }
      .map {|k,v| "#{k} (#{v.map(&:identifier).join ', '})" }
  end
end

