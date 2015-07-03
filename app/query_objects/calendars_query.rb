class CalendarsQuery
  # список онгоингов, сгруппированный по времени выхода
  def fetch_grouped
    group fetch
  end

  # список онгоингов
  def fetch
    Rails.cache.fetch [:calendar, AnimeCalendar.last.try(:id), AnimeNews.last.try(:id), Time.zone.today.to_s] do
      entries = (fetch_ongoings + fetch_anonses).map do |anime|
        AnimeDecorator.new CalendarEntry.new(anime)
      end

      exclude_overdue sort entries
      #fill_in_list entries, current_user if current_user.present?
    end
  end

private

  # определение в списке ли пользователя аниме
  #def fill_in_list entries, current_user
    #rates = Set.new current_user.anime_rates.select(:target_id).map(&:target_id)
    #entries.each do |anime|
      #anime.in_list = rates.include? anime.id
    #end
  #end

  # группировка выборки по датам
  def group entries
    entries = entries.group_by do |anime|
      key_date = if anime.ongoing?
        anime.next_episode_at || anime.episode_end_at || (anime.last_episode_date || anime.aired_on.to_datetime) + anime.average_interval
      else
        (anime.episode_end_at || anime.aired_on).to_datetime
      end

      if key_date.to_i - Time.zone.now.to_i < 0
        -1
      else
        (
          (key_date.to_i - Time.zone.now.to_i + 60*60*Time.zone.now.hour + 60*Time.zone.now.min) * 1.0 / 60 / 60 / 24
        ).to_i
      end
    end
    Hash[entries.sort]
  end

  # сортировка выборки
  def sort entries
    entries.sort_by do |v|
      if v.ongoing? && (v.episode_end_at || v.next_episode_at || v.episodes_news.any?)
        if v.episode_end_at
          v.episode_end_at.to_i
        else
          if v.next_episode_at
            v.next_episode_at.to_i
          else
            v.episodes_news.first.created_at.to_i + v.average_interval
          end
        end
      else
        (v.episode_end_at || v.aired_on).to_datetime.to_i
      end
    end
  end

  # выборка онгоингов
  def fetch_ongoings
    Anime
      .includes(:episodes_news, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :ongoing)
      .where(kind: [:tv, :ona]) # 15133 - спешл Aoi Sekai no Chuushin de
      .where.not(id: Anime::EXCLUDED_ONGOINGS + [15547]) # 15547 - Cross Fight B-Daman eS
      .where("anime_calendars.episode is null or anime_calendars.episode = episodes_aired+1")
      .where("kind != 'ona' or anime_calendars.episode is not null")
      .where("episodes_aired != 0 or aired_on  is null or aired_on > ?", Time.zone.now - 1.months)
      .order('animes.id')
  end

  # выборка анонсов
  def fetch_anonses
    Anime
      .includes(:episodes_news, :anime_calendars)
      .references(:anime_calendars)
      .where(status: :anons)
      .where(kind: [:tv, :ona])
      .where(episodes_aired: 0)
      .where.not(id: Anime::EXCLUDED_ONGOINGS)
      .where("anime_calendars.episode=1 or (anime_calendars.episode is null and aired_on >= :from and aired_on <= :to and aired_on != :new_year)",
              from: Time.zone.today - 1.week, to: Time.zone.today + 1.month, new_year: Time.zone.today.beginning_of_year)
      .where("kind != 'ona' or anime_calendars.episode is not null")
      .order('animes.id')
  end

  # выкидывание просроченных аниме
  def exclude_overdue entries
    entries.select do |v|
      (v.next_episode_at && v.next_episode_at > Time.zone.now - 1.week) ||
        v.anons?
    end
  end
end
