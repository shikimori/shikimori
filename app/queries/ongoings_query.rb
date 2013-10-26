class OngoingsQuery
  # для ignored и торренты не будут искаться
  AnimeIgnored = ([6119, 7643, 9799, 10856, 13143, 13165, 13261, 13433, 13463, 13465, 16908, 18155, 17733, 17115, 18191, 18137, 17873, 15795, 17727, 17873, 18137, 17917, 18097, 19305, 20451] + Anime::EXCLUDED_ONGOINGS).uniq

  # список онгоингов, сгруппированный по времени выхода
  def prefetch
    fetch_ongoings + fetch_anonses
  end

  # обработка онгоингов до состояния, в котором их отображать на сайте
  def process(entries, current_user, with_grouping)
    expand entries
    fill entries
    sort entries

    fill_in_list entries, current_user if current_user.present?
    if with_grouping
      group entries
    else
      entries
    end
  end

private
  # определение в списки ли пользователя аниме
  def fill_in_list(entries, current_user)
    rates = Set.new current_user.anime_rates.select(:target_id).map(&:target_id)
    entries.each do |anime|
      anime.in_list = rates.include? anime.id
    end
  end

  # группировка выборки по датам
  def group(entries)
    entries = entries.group_by do |anime|
      key_date = if anime.status == AniMangaStatus::Ongoing
        anime.next_release_at || anime.episode_end_at || (anime.last_episode_date || anime.aired_at.to_datetime) + anime.average_interval
      else
        (anime.episode_end_at || anime.aired_at).to_datetime
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

  # заполнение дополнительных полей выборки данными
  def fill(entries)
    entries.each do |v|
      if v.episodes_aired == 0
        v.average_interval = 0
      else
        v.average_interval = v.episodes_news.size < 2 ? 7.days : episode_average_interval(v)
      end
    end

    entries.each do |v|
      last_news = v.episodes_news.sort_by {|n| n.value.to_i }.last

      if v.status == AniMangaStatus::Ongoing && last_news
        v.last_episode = last_news.value.to_i+1
        v.last_episode_date = last_news.created_at
      end

      if v.anime_calendars.any?
        v.episode_start_at = v.anime_calendars.first.start_at
        v.episode_end_at = v.episode_start_at + ((v.duration || 24) + 5).minutes
      end

      v.next_release_at = v.episode_start_at if v.next_release_at.blank? && v.episode_start_at.present?
    end
  end

  # сортировка выборки
  def sort(entries)
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
        (v.episode_end_at || v.aired_at).to_datetime.to_i
      end
    end
  end

  # вычисление среднего интервала между выходами серий
  def episode_average_interval(anime)
    times = []
    prior_time = anime.episodes_news.first.created_at
    # учитываем только последние восемь записей
    anime.episodes_news.reverse.take(8).reverse.each do |news|
    #anime.news.each do |news|
      next if prior_time == news.created_at
      times << (news.created_at - prior_time).abs#/60/60/24
      prior_time = news.created_at
    end
    # считаем только по половине интервалов, отсекаем четверть самых коротких и четверть самых длинных
    times.size >= 4 ? (times.sort
                            .slice(times.size/4, times.size)
                            .take(times.size/2)
                            .sum/(times.size/2)
                      ) : times.sum/times.size
  end

  # выборка онгоингов
  def fetch_ongoings
    Anime.includes(:episodes_news, :anime_calendars)
        .where(AniMangaStatus.query_for('ongoing'))
        .where { kind.in(['TV', 'ONA']) } # 15133 - спешиал Aoi Sekai no Chuushin de
        .where { animes.id.not_in([15547]) } # 15547 - Cross Fight B-Daman eS
        .where { duration.gte(10) | duration.eq(0) }
        .where { animes.id.not_in(AnimeIgnored) }
        .where { anime_calendars.episode.eq(nil) | anime_calendars.episode.eq(animes.episodes_aired+1) }
        .where { -(kind.eq('ONA') & anime_calendars.episode.eq(nil)) }
        .where { -(episodes_aired.eq(0) & aired_at.not_eq(nil) & aired_at.lt(DateTime.now - 1.months)) }
  end

  # выборка анонсов
  def fetch_anonses
    Anime.includes(:episodes_news, :anime_calendars)
        .where(AniMangaStatus.query_for('planned'))
        .where(kind: ['TV', 'ONA'])
        .where(episodes_aired: 0)
        .where { animes.id.not_in(AnimeIgnored) }
        .where { anime_calendars.episode.eq(1) }
        .where { -(kind.eq('ONA') & anime_calendars.episode.eq(nil)) }
  end

  # добавление к записям новых полей
  def expand(entries)
    entries.each do |entry|
      class << entry
        attr_accessor :average_interval, :best_works, :last_episode, :last_episode_date, :episode_start_at, :episode_end_at, :in_list
      end
    end
  end
end
