class CalendarsQuery
  ONGOINGS_SQL = <<~SQL
    animes.broadcast is not null or
      (next_episode_at is not null and next_episode_at > (now() - interval '1 day')) or
      anime_calendars.episode is null or
      anime_calendars.episode = episodes_aired + 1
  SQL

  ANNOUNCED_FROM = 1.week
  ANNOUNCED_UNTIL = 1.month

  def initialize scope = Anime.all
    @scope = scope
  end

  def fetch_grouped
    group fetch
  end

  def fetch
    entries = (fetch_ongoings + fetch_announced)
      .map { |anime| CalendarEntry.new(anime.decorate) }
      # .select { |v| v.id == 41_206 }

    exclude_overdue(
      entries
        .select(&:next_episode_start_at)
        .sort_by(&:next_episode_start_at)
    )
  end

  def cache_key
    [
      :calendar,
      AnimeCalendar.last.try(:id),
      Topics::NewsTopic.last.try(:id),
      Time.zone.today.to_s,
      :v4
    ]
  end

private

  def group entries
    entries = entries.group_by do |anime|
      # key_date = if anime.ongoing?
        # anime.next_episode_at || anime.episode_end_at ||
        # (anime.last_episode_date || anime.aired_on.date.to_datetime) + anime.average_interval
      # else
      # (anime.episode_end_at || anime.aired_on.date).to_datetime
      # end
      key_date = anime.next_episode_start_at

      if (key_date.to_i - Time.zone.now.to_i).negative?
        -1
      else
        (
          (
            key_date.to_i -
              Time.zone.now.to_i +
              60 * 60 * Time.zone.now.hour +
              60 * Time.zone.now.min
          ) * 1.0 / 60 / 60 / 24
        ).to_i
      end
    end
    Hash[entries.sort]
  end

  def fetch_ongoings
    @scope
      .includes(:episode_news_topics, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :ongoing)
      .where(kind: %i[tv ona])
      .where.not(id: Anime::EXCLUDED_ONGOINGS + [15_547])
      .where(Arel.sql(ONGOINGS_SQL))
      .where(
        'episodes_aired != 0 or (aired_on_computed is not null and aired_on_computed > ?)',
        1.month.ago
      )
      .order(Arel.sql('animes.id'))
  end

  def fetch_announced
    @scope
      .includes(:episode_news_topics, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :anons)
      .where(kind: %i[tv ona])
      .where.not(id: Anime::EXCLUDED_ONGOINGS)
      .where(
        "(
          anime_calendars.start_at is not null and
            start_at >= :from and
            start_at <= :to
        ) or (
          aired_on_computed >= :from and
            aired_on_computed <= :to and aired_on_computed != :new_year
        )",
        from: ANNOUNCED_FROM.ago.to_date,
        to: ANNOUNCED_UNTIL.from_now.to_date,
        new_year: Time.zone.today.beginning_of_year.to_date
      )
      .where.not(
        Arel.sql("
          anime_calendars.episode is null
            and aired_on->>'day' is null
            and aired_on->>'month' is null
        ")
      )
      .order(Arel.sql('animes.id'))
      # .where(Arel.sql("kind != 'ona' or anime_calendars.episode is not null"))
  end

  def exclude_overdue entries
    entries.select do |v|
      (v.next_episode_start_at && v.next_episode_start_at > 1.week.ago) ||
        v.anons?
    end
  end
end
