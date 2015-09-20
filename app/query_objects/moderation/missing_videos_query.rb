class Moderation::MissingVideosQuery
  prepend ActiveCacher.instance

  pattr_initialize :kind
  instance_cache :missing_videos

  LIMIT = 300

  MISSING_EPISODES_QUERY = <<-sql
    select
      distinct(episode), anime_id
    from
      anime_videos
    where
      episode != 0
      and (state = 'working' or state = 'uploaded')
      and kind != 'raw'
sql

  ANIME_CONDITION = <<-sql
    animes.id in (
      select
        animes.id
      from
        animes
      inner join user_rates
        on user_rates.target_id = animes.id
          and user_rates.target_type = 'Anime'
      where
        animes.score > 6.5
        and animes.rating != 'g'
        and animes.rating != 'rx'
        and (
          animes.status = 'ongoing'
          or animes.status = 'released'
        )
        and animes.ranked != 0
      group by
        animes.id
      having
        count(*) > #{Rails.env.test? ? 0 : (User.count / 1000.0).to_i}
    )
sql

  MISSING_VIDEOS_QUERY = <<-sql
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
      #{MISSING_EPISODES_QUERY} %s
    ) working_videos on animes.id = working_videos.anime_id
    where
      #{ANIME_CONDITION}
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
sql

  CONDITIONS_BY_KIND = {
    all: '',
    vk: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%')",
    subbed: "and kind = 'subtitles'",
    dubbed: "and kind = 'fandub'",
    vk_subbed: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%') and kind = 'subtitles'",
    vk_dubbed: "and (url like 'https://vk.com/%' or url like 'http://vk.com/%') and kind = 'fandub'"
  }

  def animes
    Anime
      .where(id: missing_videos.keys)
      .order(:ranked)
      .map do |anime|
        missing_videos[anime.id].anime = anime
        missing_videos[anime.id]
      end
  end

  def episodes anime
    total_episodes = anime.released? || anime.episodes_aired.zero? ?
      anime.episodes : anime.episodes_aired
    present_episodes = execute(
      MISSING_EPISODES_QUERY + condition + " and anime_id=#{Anime.sanitize anime.id} "
    ).map { |v| v['episode'].to_i }

    (1..total_episodes).to_a - present_episodes
  end

private

  def missing_videos
    execute(MISSING_VIDEOS_QUERY % condition).each_with_object({}) do |row, memo|
      memo[row['anime_id'].to_i] = OpenStruct.new row
    end
  end

  def execute query
    ActiveRecord::Base.connection.execute(query).to_a
  end

  def condition
    CONDITIONS_BY_KIND[kind.to_sym] || raise(ArgumentError, "unexpected kind: #{kind}")
  end
end
