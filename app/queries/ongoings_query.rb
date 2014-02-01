class OngoingsQuery
  # список онгоингов, сгруппированный по времени выхода
  def fetch
    entries = (fetch_ongoings + fetch_anonses).map {|anime| OngoingEntry.new anime }

    sort entries
    exclude_overdue entries
    #fill_in_list entries, current_user if current_user.present?
    group entries
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
      key_date = if anime.status == AniMangaStatus::Ongoing
        anime.next_release_at || anime.episode_end_at || (anime.last_episode_date || anime.aired_on.to_datetime) + anime.average_interval
      else
        (anime.episode_end_at || anime.aired_on).to_datetime
      end

      if key_date.to_i - DateTime.now.to_i < 0
        -1
      else
        (
          (key_date.to_i - DateTime.now.to_i + 60*60*DateTime.now.hour + 60*DateTime.now.min) * 1.0 / 60 / 60 / 24
        ).to_i
      end
    end
    Hash[entries.sort]
  end

  # сортировка выборки
  def sort entries
    entries.sort_by do |v|
      if v.status == AniMangaStatus::Ongoing && (v.episode_end_at || v.next_release_at || v.episodes_news.any?)
        if v.episode_end_at
          v.episode_end_at.to_i
        else
          if v.next_release_at
            v.next_release_at.to_i
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
      .where(AniMangaStatus.query_for('ongoing'))
      .where { kind.in(['TV', 'ONA']) } # 15133 - спешиал Aoi Sekai no Chuushin de
      .where { animes.id.not_in([15547]) } # 15547 - Cross Fight B-Daman eS
      .where { animes.id.not_in(Anime::EXCLUDED_ONGOINGS) }
      .where { anime_calendars.episode.eq(nil) | anime_calendars.episode.eq(animes.episodes_aired+1) }
      .where { -(kind.eq('ONA') & anime_calendars.episode.eq(nil)) }
      .where { -(episodes_aired.eq(0) & aired_on.not_eq(nil) & aired_on.lt(DateTime.now - 1.months)) }
      #.where { duration.gte(10) | duration.eq(0) }
  end

  # выборка анонсов
  def fetch_anonses
    Anime
      .includes(:episodes_news, :anime_calendars)
      .references(:anime_calendars)
      .where(AniMangaStatus.query_for('planned'))
      .where(kind: ['TV', 'ONA'])
      .where(episodes_aired: 0)
      .where { animes.id.not_in(Anime::EXCLUDED_ONGOINGS) }
      .where("anime_calendars.episode=1 or (aired_on >= :from and aired_on <= :to and aired_on != :new_year)",
              from: Date.today - 1.week, to: Date.today + 1.month, new_year: Date.today.beginning_of_year)
      .where { -(kind.eq('ONA') & anime_calendars.episode.eq(nil)) }
  end

  # выкидывание просроченных аниме
  def exclude_overdue entries
    entries.select! {|v| v.next_release_at && v.next_release_at > DateTime.now - 1.week }
  end
end
