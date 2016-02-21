require_dependency 'traffic_entry'
require_dependency 'calendar_entry'
require_dependency 'site_statistics'

class TestsController < ShikimoriController
  # тестовая страница
  def show
    @traffic = Rails.cache.fetch("traffic_#{Date.today}") { YandexMetrika.new.traffic_for_months 18 }
  rescue Faraday::ConnectionFailed
  end

  # тест d3 графа
  def d3
    @anime = Anime.find params[:anime_id]
    render :d3, layout: false
  end

  # страница для теста рамок
  def border
  end

  def momentjs
  end

  def webm
    render :webm, layout: false
  end

  def vk_video
    @video = AnimeVideo.find(846660).decorate
    render :vk_video, layout: false
  end

  def wall
  end

  def ajax
  end

  def colors
  end

  #def d3_data
    #query = ChronologyQuery.new(Anime.find params[:anime_id])
    #@entries = query.fetch
    #@links = query.links
  #end
end
