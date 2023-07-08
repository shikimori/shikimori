class SmotretAnime::ScheduleEpisodeWorkers
  include Sidekiq::Worker
  sidekiq_options queue: :default

  Group = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:a, :b, :c)

  GROUP_SQL = {
    Group[:a] => 'score > 7',
    Group[:b] => 'score <= 7 and score > 6',
    Group[:c] => 'score <= 6'
  }

  def perform group
    scope
      .joins(:smotret_anime_external_link)
      .where(
        "not(options @> ARRAY['#{Types::Anime::Options[:disabled_anime365_sync]}']::varchar[])"
      )
      .where(GROUP_SQL[Group[group]])
      .order('animes.id')
      .each do |anime|
        smotret_anime_id = Animes::SmotretAnimeId.call anime

        if smotret_anime_id
          SmotretAnime::EpisodeWorker.perform_async anime.id, smotret_anime_id
        end
      end
  end

  private

  def scope
    Anime
      .where(status: :ongoing)
      .or(
        Anime.where(
          'status = :status and aired_on_computed is not null and aired_on_computed < :date',
          status: :anons,
          date: 1.week.from_now
        )
      )
  end
end
