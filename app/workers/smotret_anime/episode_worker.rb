class SmotretAnime::EpisodeWorker
  include Sidekiq::Worker
  sidekiq_options(
    queue: :anime365_parsers,
    retry: false
  )

  EPISODES_API_URL = 'https://smotret-anime.online/api/series/%<smotret_anime_id>i?fields=id,episodes'
  TRUST_INTERVAL = 3.hours

  NO_DATE = '2000-01-01 00:00:00'

  def perform anime_id, smotret_anime_id
    anime = Anime.find_by id: anime_id

    data = fetch format(EPISODES_API_URL, smotret_anime_id: smotret_anime_id)

    if data
      episodes = extract data[:episodes] || [], anime.kind, anime.episodes_aired
      episodes.each { |episode| track anime, episode }
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

  def track anime, episode
    EpisodeNotification::Track.call(
      anime: anime,
      episode: episode[:episode],
      aired_at: episode[:aired_at],
      is_anime365: true
    )
  end

  def extract episodes, kind, episodes_aired
    episodes
      .select { |entry| valid? entry, kind }
      .map do |entry|
        {
          episode: entry[:episodeInt].to_i,
          aired_at: Time.zone.parse(entry[:firstUploadedDateTime])
        }
      end
      .select { |v| v[:episode].to_i > episodes_aired && v[:aired_at] < TRUST_INTERVAL.ago }
      .sort_by { |v| v[:episode] }
  end

  def valid? entry, kind
    matched_kind?(entry[:episodeType], kind) &&
      entry[:isActive] == 1 &&
      entry[:isFirstUploaded] == 1 &&
      entry[:firstUploadedDateTime] != NO_DATE
  end

  def matched_kind? episode_type, kind
    episode_type == kind || (kind == 'ona' && episode_type == 'tv')
  end

  def fetch url
    JSON.parse(
      OpenURI.open_uri(url, 'User-Agent' => 'shikimori').read,
      symbolize_names: true
    )[:data]
  end
end
