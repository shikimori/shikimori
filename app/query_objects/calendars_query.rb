class CalendarsQuery
  ONGOINGS_SQL = <<~SQL
    animes.broadcast is not null or
      (next_episode_at is not null and next_episode_at > (now() - interval '1 day')) or
      anime_calendars.episode is null or
      anime_calendars.episode = episodes_aired + 1
  SQL

  # список онгоингов, сгруппированный по времени выхода
  def fetch_grouped locale
    group fetch(locale)
  end

  # список онгоингов
  def fetch locale
    # Rails.cache.fetch cache_key do
    entries = (fetch_ongoings + fetch_anonses).map do |anime|
      AnimeDecorator.new CalendarEntry.new(anime, locale)
    end

    exclude_overdue(
      entries
        .select(&:next_episode_start_at)
        .sort_by(&:next_episode_start_at)
    )
      # fill_in_list entries, current_user if current_user.present?
    # end
  end

  def cache_key
    [
      :calendar,
      :v3,
      AnimeCalendar.last.try(:id),
      Topics::NewsTopic.last.try(:id),
      Time.zone.today.to_s
    ]
  end

private

  # определение в списке ли пользователя аниме
  # def fill_in_list entries, current_user
    # rates = Set.new current_user.anime_rates.select(:target_id).map(&:target_id)
    # entries.each do |anime|
      # anime.in_list = rates.include? anime.id
    # end
  # end

  # группировка выборки по датам
  def group entries
    entries = entries.group_by do |anime|
      # key_date = if anime.ongoing?
        # anime.next_episode_at || anime.episode_end_at ||
          # (anime.last_episode_date || anime.aired_on.to_datetime) + anime.average_interval
      # else
        # (anime.episode_end_at || anime.aired_on).to_datetime
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

  # выборка онгоингов
  def fetch_ongoings
    Anime
      .includes(:episode_news_topics, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :ongoing) # .where(id: 31680)
      .where(kind: %i[tv ona]) # 15133 - спешл Aoi Sekai no Chuushin de
      .where.not(id: Anime::EXCLUDED_ONGOINGS + [15_547]) # 15547 - Cross Fight B-Daman eS
      .where(Arel.sql(ONGOINGS_SQL))
      .where(
        'episodes_aired != 0 or (aired_on is not null and aired_on > ?)',
        Time.zone.now - 1.months
      )
      .order(Arel.sql('animes.id'))
  end

  # выборка анонсов
  def fetch_anonses
    Anime
      .includes(:episode_news_topics, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :anons) # .where(id: 31680)
      .where(kind: %i[tv ona])
      .where(episodes_aired: 0)
      .where.not(id: Anime::EXCLUDED_ONGOINGS)
      .where(
        "anime_calendars.episode=1 or (
          anime_calendars.episode is null and aired_on >= :from and
          aired_on <= :to and aired_on != :new_year)",
        from: Time.zone.today - 1.week,
        to: Time.zone.today + 1.month,
        new_year: Time.zone.today.beginning_of_year
      )
      .where(Arel.sql("kind != 'ona' or anime_calendars.episode is not null"))
      .where.not(
        Arel.sql(
          "anime_calendars.episode is null
          and date_part('day', aired_on) = 1
          and date_part('month', aired_on) = 1"
        )
      )
      .order(Arel.sql('animes.id'))
  end

  # выкидывание просроченных аниме
  def exclude_overdue entries
    entries.select do |v|
      (v.next_episode_start_at && v.next_episode_start_at > Time.zone.now - 1.week) ||
        v.anons?
    end
  end
end
