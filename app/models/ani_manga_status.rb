class AniMangaStatus
  Ongoing = 'Currently Airing'
  Anons = 'Not yet aired'
  Released = 'Finished Airing'
  Finished = 'Finished'
  Publishing = 'Publishing'
  Upcoming = 'Not yet published'

  @all = [
    ['planned', 'Анонсировано'],
    ['ongoing', 'Онгоинг'],
    ['latest', 'Недавно вышедшее'],
    ['released', 'Вышедшее']
    #['favourite', 'Избранное']
  ]

  def self.all
    @all
  end

  def self.query_for(status, klass=Anime)
    released_status = klass == Anime ? AniMangaStatus::Released : AniMangaStatus::Finished

    case status
      when 'ongoing'
        "((aired_on is not null and aired_on < '%s 00:00:00' and status in ('%s', '%s')) " % [Date.today-AniManga::OngoingToReleasedDays.days, AniMangaStatus::Anons, AniMangaStatus::Upcoming] +
        " or (aired_on is not null and status in ('%s','%s'))) " % [AniMangaStatus::Ongoing, AniMangaStatus::Publishing] +
        "and not (aired_on is not null and released_on is not null and aired_on < date_add(now(), interval -#{AniManga::OngoingToReleasedDays} day) && released_on < date_add(now(), interval -7 day))" +
        "and not (status in ('%s', '%s') and aired_on = '%s-01-01 00:00:00') " % [AniMangaStatus::Anons, AniMangaStatus::Upcoming, Date.today.year] +
        "and #{klass.name.tableize}.id not in (%s)" % klass::EXCLUDED_ONGOINGS.join(',')

      when 'latest'
        "status = '%s' and (released_on > '%s 00:00:00' or (aired_on > '%s 00:00:00' and released_on is null)) " % [released_status, Date.today - 3.month, Date.today - 3.month] +
        "and #{klass.name.tableize}.id not in (%s)" % (klass::EXCLUDED_ONGOINGS).join(',')

      when 'planned'
        "status in ('%s', '%s') and not (%s)" % [AniMangaStatus::Anons, AniMangaStatus::Upcoming, self.query_for('ongoing', klass)]

      when 'released'
        "status = '#{released_status}'"

      when 'favourite'
        "id in (%s)"% Favourite.where(:linked_type => Anime.name).group(:linked_id).map(&:linked_id).join(',')

      else
        raise BadStatusError, "unknown status '#{status}'"
    end
  end
end
