class AnimeDecorator < AniMangaDecorator
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
    @files ||= AniMangaPresenter::FilesPresenter.new object, h
  end

  # ролики, отображаемые на инфо странице аниме
  def main_videos
    @main_videos ||= object.videos.limit(2)
  end
end
