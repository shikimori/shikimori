class AnimeDecorator < AniMangaDecorator
  instance_cache :files, :next_episode_at

  # скриншоты
  def screenshots limit=nil
    (@screenshots ||= {})[limit] ||= if object.respond_to? :screenshots
      object.screenshots.limit limit
    else
      []
    end
  end

  # видео
  def videos limit=nil
    (@videos ||= {})[limit] ||= if object.respond_to? :videos
      object.videos.limit limit
    else
      []
    end
  end

  # презентер файлов
  def files
    AniMangaPresenter::FilesPresenter.new object, h
  end

  # дата выхода следующего эпизода
  def next_episode_at
    if episodes_aired && (ongoing? || anons?)
      calendars = anime_calendars.where(episode: [episodes_aired + 1, episodes_aired + 2]).to_a

      if calendars[0].present? && calendars[0].start_at > Time.zone.now
        calendars[0].start_at

      elsif calendars[1].present?
        calendars[1].start_at
      end
    end || object.next_episode_at
  end

  # для анонса перебиваем дату анонса на дату с анимекалендаря, если таковая имеется
  def aired_on
    anons? && next_episode_at ? next_episode_at : object.aired_on
  end
end
