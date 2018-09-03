require_dependency 'traffic_entry'
require_dependency 'calendar_entry'
require_dependency 'site_statistics'

class TestsController < ShikimoriController
  skip_before_action :verify_authenticity_token, only: [:echo]

  def show
    @traffic = Rails.cache.fetch("traffic_#{Time.zone.today}") do
      YandexMetrika.call 18
    end
  rescue Faraday::ConnectionFailed
  end

  def echo
    NamedLogger.echo.info params.to_yaml
    render json: params
  end

  # тест d3 графа
  def d3
    @anime = Anime.find params[:anime_id]
    render :d3, layout: false
  end

  # страница для теста рамок
  def border
  end

  def animes
    @resource = Anime.find(9969).decorate
    @collection_1 = [@resource, Anime.find(31_240).decorate, @resource]
    @collection_2 = [@resource] + Anime
      .where('score > 8 and score < 9')
      .order(id: :desc)
      .limit(5)
      .decorate
  end

  def achievements_notification
  end

  def momentjs
  end

  def webm
    render :webm, layout: false
  end

  def polls
  end

  def vk_video
    @video = AnimeVideo.find(846_660).decorate
    render :vk_video, layout: false
  end

  def wall
  end

  def ajax
  end

  def colors
  end

  # def d3_data
    # query = Animes::ChronologyQuery.new(Anime.find params[:anime_id])
    # @entries = query.fetch
    # @links = query.links
  # end

  def iframe
  end

  def iframe_inner
    render :iframe_inner, layout: false
  end
end
