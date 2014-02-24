class AnimeLinksVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    raise "Ambiguous anime links found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    AnimeLink
      .where(service: [FindAnimeImporter::SERVICE, HentaiAnimeImporter::SERVICE])
      .all
      .group_by {|v| v.anime_id }
      .select {|k,v| v.size > 1 }
      .map {|k,v| "#{k} (#{v.map(&:identifier).join ', '})" }
  end
end

