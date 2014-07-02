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
        "((aired_on is not null and aired_on < '#{AniManga::OngoingToReleasedDays.days.ago.to_date}' and status in ('#{AniMangaStatus::Anons}', '#{AniMangaStatus::Upcoming}')) " +
        " or (aired_on is not null and status in ('#{AniMangaStatus::Ongoing}', '#{AniMangaStatus::Publishing}'))) " +
        "and not (aired_on is not null and released_on is not null and aired_on < '#{AniManga::OngoingToReleasedDays.days.ago.to_date}' and released_on < '#{7.days.ago.to_date}')" +
        "and not (status in ('#{AniMangaStatus::Anons}', '#{AniMangaStatus::Upcoming}') and aired_on = '#{Date.today.year}-01-01') " +
        "and #{klass.name.tableize}.id not in (#{klass::EXCLUDED_ONGOINGS.join ','})"

      when 'latest'
        "status = '#{released_status}' and (released_on > '#{3.month.ago.to_date}' or (aired_on > '#{3.month.ago.to_date}' and released_on is null)) " +
        "and #{klass.name.tableize}.id not in (#{klass::EXCLUDED_ONGOINGS.join ','})"

      when 'planned'
        "status in ('#{AniMangaStatus::Anons}', '#{AniMangaStatus::Upcoming}') and not (#{query_for 'ongoing', klass})"

      when 'released'
        "status = '#{released_status}'"

      when 'favourite'
        "id in (%s)"% Favourite.where(linked_type: Anime.name).group(:linked_id).map(&:linked_id).join(',')

      else
        raise BadStatusError, "unknown status '#{status}'"
    end
  end
end
