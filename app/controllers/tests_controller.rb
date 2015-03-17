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

  #def d3_data
    #query = ChronologyQueryV2.new(Anime.find params[:anime_id])
    #@entries = query.fetch
    #@links = query.links
  #end
end
