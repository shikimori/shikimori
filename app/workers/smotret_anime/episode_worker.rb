class SmotretAnime::EpisodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :anime365_parsers

  EPISODES_API_URL = 'https://smotretanime.ru/api/series/%<smotret_anime_id>i?fields=id,episodes'
  TRUST_INTERVAL = 3.hours

  NO_DATE = '2000-01-01 00:00:00'

  def perform anime_id, smotret_anime_id
    anime = Anime.find_by id: anime_id

    data = fetch format(EPISODES_API_URL, smotret_anime_id: smotret_anime_id)

    if data
      episodes = extract data[:episodes], anime.kind, anime.episodes_aired
      episodes.each { |episode| track anime.id, episode }
    else
      unlink anime, smotret_anime_id
    end
  end

private

  def unlink anime, smotret_anime_id
    NamedLogger.smotret_anime.info(
      "unlink anime_id=#{anime.id} smotret_anime_id=#{smotret_anime_id}"
    )

    anime
      .all_external_links
      .where(source: Types::ExternalLink::Source[:smotret_anime])
      .destroy_all
  end

  def track anime_id, episode
    EpisodeNotification::Track.call(
      anime_id: anime_id,
      episode: episode[:episode],
      aired_at: episode[:aired_at],
      is_raw: true
    )
  end

  def extract episodes, kind, episodes_aired
    (episodes || [])
      .select do |episode|
        episode[:episodeType] == kind && episode[:isActive] == 1 &&
          episode[:firstUploadedDateTime] != NO_DATE
      end
      .map do |episode|
        {
          episode: episode[:episodeInt].to_i,
          aired_at: Time.zone.parse(episode[:firstUploadedDateTime])
        }
      end
      .select { |v| v[:episode].to_i > episodes_aired && v[:aired_at] < TRUST_INTERVAL.ago }
      .sort_by { |v| v[:episode] }
  end

  def fetch url
    JSON.parse(
      OpenURI.open_uri(url, 'User-Agent' => 'shikimori').read,
      symbolize_names: true
    )[:data]
  end
end
