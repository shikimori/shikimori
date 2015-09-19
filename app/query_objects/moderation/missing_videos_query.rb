class Moderation::MissingVideosQuery
  prepend ActiveCacher.instance

  pattr_initialize :kind
  instance_cache :missing_videos

  LIMIT = 300
  MISSING_VIDEOS_QUERY = <<-eos
    select
      count(working_videos.episode) as present_episodes,
      (
        case when animes.status = 'released' or max(animes.episodes_aired) = 0
          then max(animes.episodes)
          else max(animes.episodes_aired) end
      ) as total_episodes,
      animes.id as anime_id
    from animes
    left join (
      select
        distinct(episode), anime_id
      from
        anime_videos
      where
        episode != 0
        and (state = 'working' or state = 'uploaded')
        and kind != 'raw'
        %s
    ) working_videos on animes.id = working_videos.anime_id
    where
      ranked != 0
      and score > 6.5
      and rating != 'g'
      and rating != 'rx'
      and (animes.status = 'ongoing' or animes.status = 'released')
    group by
      animes.id
    having
      count(working_videos.episode) != 0 and
      count(working_videos.episode) < (
        case when animes.status = 'released' or max(animes.episodes_aired) = 0
          then max(animes.episodes)
          else max(animes.episodes_aired) end
      )
    limit #{LIMIT}
eos

  CONDITIONS_BY_KIND = {
    all: '',
    vk: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%')",
    subbed: "and kind = 'subtitles'",
    dubbed: "and kind = 'fandub'",
    vk_subbed: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%') and kind = 'subtitles'",
    vk_dubbed: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%') and kind = 'fandub'"
  }

  def fetch
    Anime
      .where(id: missing_videos.keys)
      .order(:ranked)
      .map do |anime|
        missing_videos[anime.id].anime = anime
        missing_videos[anime.id]
      end
  end

private

  def missing_videos
    Anime.connection
      .execute(query)
      .each_with_object({}) do |row, memo|
        memo[row['anime_id'].to_i] = OpenStruct.new row
      end
  end

  def query
    MISSING_VIDEOS_QUERY % [
      CONDITIONS_BY_KIND[kind.to_sym] || raise(ArgumentError, "unexpected kind: #{kind}")
    ]
  end
end
