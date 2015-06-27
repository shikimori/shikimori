# TODO: отрефакторить толстый контроллер
class RecommendationsController < AnimesCollectionController
  before_action :authenticate_user!, if: -> { json? }
  before_action -> { page_title I18n.t("Name.#{klass.name}") }
  layout false, only: [:test]

  COOKIE_NAME = 'recommendations_url'
  THRESHOLDS = {
    Anime => [250, 500, 700, 1000, 1250],
    Manga => [15, 45, 100, 150]
  }
  TOPIC_URL = 'http://shikimori.org/s/104346-spisok-otbornyh-i-vkusnyh-animeh'

  def index
    @threshold = params[:threshold].to_i
    @metric = params[:metric]

    return redirect_to recommendations_url(url_params(metric: 'pearson_z')) if @metric.blank?
    unless THRESHOLDS[klass].include? @threshold
      return redirect_to recommendations_url(url_params(threshold: THRESHOLDS[klass][-1]))
    end

    page_title 'Персонализированные рекомендации'

    # запоминание текущего типа рекомендаций в куку, чтобы в меню верхнем ссылка корректная была
    cookies[COOKIE_NAME] = request.url unless params[:page]

    # параметры для аниме контроллера
    params[:template] = 'index'

    # можно смотреть чужие рекоменадции
    user = if params[:user].blank? || !user_signed_in? || (user_signed_in? && current_user.id != 1 && current_user.id != 1945) # 1945 - Silicium
      user_signed_in? ? current_user.object : nil
    else
      User.find_by(nickname: SearchHelper.unescape(params[:user])) || User.find_by(id: params[:user])
    end

    @rankings = Recommendations::Fetcher.new(user, klass, @metric, @threshold).fetch

    if @rankings.present?
      @entries = []

      if @rankings.any?
        params[:ids_with_sort] = @rankings

        params[:exclude_ai_genres] = true
        params[:exclude_ids] = user
          .send("#{klass.name.downcase}_rates")
          .includes(klass.name.downcase.to_sym).inject([]) do |result, v|
            result << v.target_id unless v.planned?
            result
          end
      end

      super
    else
      respond_to do |format|
        format.html do
          params[:ids_with_sort] = {}
          super
        end
        format.json do
          render json: { pending: true }
        end
      end
    end
  end

  def favourites
    page_title klass == Anime ? 'Какие аниме посмотреть' : 'Какую мангу почитать'

    cache_key = [:favourites_recommendations, :v1, klass, current_user, current_user.try(:sex)]
    @entries = Rails.cache.fetch cache_key, expires_in: 1.week do
      FavouritesQuery.new
        .global_top(klass, klass == Anime ? 500 : 1000, current_user)
        .group_by { |v| v.anime? && (v.ova? || v.ona?) ? 'OVA/ONA' : v.kind }
        .each_with_object({}) do |(kind, group), memo|
          limit = if klass == Anime
            kind == :tv ? 18 : (kind == :movie ? 12 : 8)
          else
            kind == :manga ? 18 : (kind == :one_shot || kind == :doujin ? 8 : 12)
          end
          memo[kind] = group.take(limit).map(&:decorate)
        end
    end
  end

  def test
    @limit = [500, params[:users].to_i.abs].min
    @threshold = [200, [0, params[:threshold].to_i].max].min

    users = [user_signed_in? ? current_user.object : nil].compact +
      User.where(id: [1]) + SiteStatistics.new.newsmakers + SiteStatistics.new.thanks_to + User.find(1).friends
    @users = users.compact.uniq# .select {|v| [2].include? v.id }
      .select {|v| v.anime_rates.where('score > 0').size > 50 }
      .sort_by {|v| user_signed_in? ? [v.id == current_user.id ? 1 : 2, v.id] : v.id }
      .take(@limit)
    user_ids = @users.map(&:id)

    @rates_fetcher = Recommendations::RatesFetcher.new Anime
    entries_fetcher = Recommendations::EntriesFetcher.new Anime

    avg = Recommendations::Metrics::AvgScore.new
    euclid = Recommendations::Metrics::Euclid.new
    pearson = Recommendations::Metrics::Pearson.new
    svd = Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :none).last!)
    svd_mean_centering = Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :mean_centering).last!)
    svd_z_score = Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :z_score).last!)

    no_norm = Recommendations::Normalizations::None.new
    mean_centering = Recommendations::Normalizations::MeanCentering.new
    z_score = Recommendations::Normalizations::ZScore.new
    #z_score_centering = Recommendations::Normalizations::ZScoreCentering.new

    @all_user_ids = (user_ids + @rates_fetcher.fetch(no_norm).keys).uniq.take(@limit)

    #avg = Recommendations::Sampler.new Anime, Recommendations::Metrics::AvgScore.new(entries_fetcher), rates_fetcher, no_norm, ''
    #euclid = Recommendations::Sampler.new Anime, Recommendations::Metrics::Euclid.new, rates_fetcher, no_norm, ''

    #pearson = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, no_norm, ''
    #pearson_mean = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, mean_centering, ''
    #pearson_z = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, z_score, ''

    ##svd_full = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.full), rates_fetcher, z_score, ''
    #svd = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.partial), rates_fetcher, no_norm, ''
    #svd_mean = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.partial), rates_fetcher, mean_centering, ''
    #svd_z = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.partial), rates_fetcher, z_score, ''


    NamedLogger.recommendations.info 'sampling started'.light_green
    @metrics = {
      ##'Average no normalization' => calc(avg, no_norm),
      ##'Average Mean-centering normalization' => calc(avg, mean_centering),
      ##'Average Z-score normalization' => calc(avg, z_score),
      #'Euclid no normalization' => calc(euclid, no_norm),
      #'Euclid Mean-centering normalization' => calc(euclid, mean_centering),
      'Euclid Z-score normalization' => calc(euclid, z_score),
      #'Pearson' => calc(pearson, no_norm),
      #'Pearson Mean-centering normalization' => calc(pearson, mean_centering),
      'Pearson Z-score' => calc(pearson, z_score),
      'SVD no normalization' => calc(svd, no_norm),
      #'SVD Mean-centering normalization' => calc(svd_mean_centering, mean_centering),
      'SVD Z-score normalization' => calc(svd_z_score, z_score),
    }
    NamedLogger.recommendations.info 'sampling finished'.light_green
    #@metrics.each {|metric, data| data.select! {|k,v| !v.nan? } }

    @users = [User.new(nickname: "Статистика (#{@all_user_ids.size} человек)")] + @users
    @users[0].id = -1
  end

  def calc metric, normalization
    @all_user_ids.each_with_object({}) do |user_id, memo|
      sampler = Recommendations::Sampler.new Anime, metric, @rates_fetcher, normalization, user_id
      memo[user_id] = sampler.rmse user_id, @threshold
    end
  end
end
