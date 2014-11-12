# TODO: отрефакторить толстый контроллер
class RecommendationsController < AnimesCollectionController
  before_filter :authenticate_user!, if: -> { json? }

  CookieName = 'rec_type'
  THRESHOLDS = {
    Anime => [150, 350, 500, 700, 1000],
    Manga => [15, 45, 100, 150]
  }

  def index
    @klass = params[:klass] == Manga.name.downcase ? Manga : Anime
    @threshold = params[:threshold].to_i
    @metric = params[:metric]

    redirect_to recommendations_url(params.merge metric: 'pearson_z') and return if @metric.blank?
    unless THRESHOLDS[@klass].include? @threshold
      redirect_to recommendations_url(params.merge threshold: THRESHOLDS[@klass][-1])
      return
    end

    # запоминание текущего типа рекомендаций в куку, чтобы в меню верхнем ссылка корректная была
    cookies[CookieName] = @klass.name.downcase if @klass.name.downcase != cookies[CookieName]

    # параметры для аниме контроллера
    params[:template] = 'index'

    # можно смотреть чужие рекоменадции
    user = if params[:user].blank? || !user_signed_in? || (user_signed_in? && current_user.id != 1 && current_user.id != 1945) # 1945 - Silicium
      user_signed_in? ? current_user.object : nil
    else
      User.find_by_nickname(SearchHelper.unescape(params[:user])) || User.find_by_id(params[:user])
    end

    @page_title = "Рекомендации #{@klass == Anime ? 'аниме' : 'манги'}"
    @title_notice = "На данной странице отображен список #{@klass == Anime ? 'аниме' : 'манги'}, автоматически #{@klass == Anime ? 'подобранных' : 'подобранной'} сайтом, исходя из оценок похожих на вас людей"

    @rankings = Recommendations::Fetcher.new(user, @klass, @metric, @threshold).fetch

    if @rankings.present?
      @entries = []

      if @rankings.any?
        params[:ids_with_sort] = @rankings

        params[:exclude_ids] = user.send("#{klass.name.downcase}_rates").includes(klass.name.downcase.to_sym).inject([]) do |result, v|
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

  def test
    @limit = [500, params[:users].to_i.abs].min
    @threshold = [200, [0, params[:threshold].to_i].max].min

    users = [user_signed_in? ? current_user : nil].compact +
        User.where(id: [1,1945,2033]) + User.find(1).friends
    @users = users
        .compact
        .uniq
        .select {|v| v.nickname != 'Con_Affetto' && v.anime_rates.where { score > 0 }.size > 50 }
        .sort_by {|v| user_signed_in? ? [v.id == current_user.id ? 1 : 2, v.id] : v.id }
        .take(@limit)
    user_ids = @users.map(&:id)

    no_norm = Recommendations::Normalizations::None.new
    mean_centering = Recommendations::Normalizations::MeanCentering.new
    z_score = Recommendations::Normalizations::ZScore.new

    rates_fetcher = Recommendations::RatesFetcher.new Anime
    entries_fetcher = Recommendations::EntriesFetcher.new Anime

    all_user_ids = (user_ids + rates_fetcher.fetch(no_norm).keys).uniq.take(@limit)

    avg = Recommendations::Sampler.new Anime, Recommendations::Metrics::AvgScore.new(entries_fetcher), rates_fetcher, no_norm, ''
    euclid = Recommendations::Sampler.new Anime, Recommendations::Metrics::Euclid.new, rates_fetcher, no_norm, ''

    pearson = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, no_norm, ''
    pearson_mean = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, mean_centering, ''
    pearson_z = Recommendations::Sampler.new Anime, Recommendations::Metrics::Pearson.new, rates_fetcher, z_score, ''

    svd_full = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.full), rates_fetcher, z_score, ''
    svd_partial = Recommendations::Sampler.new Anime, Recommendations::Metrics::SvdMetric.new(Svd.partial), rates_fetcher, z_score, ''

    @metrics = {
      #'Average Score' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = avg.rmse user_id, @threshold
      #end,
      #'Euclid' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = euclid.rmse user_id, @threshold
      #end,
      #'Pearson' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = pearson.rmse user_id, @threshold
      #end,
      #'Pearson Mean-centering' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = pearson_mean.rmse user_id, @threshold
      #end,
      'Pearson Z-score' => all_user_ids.each_with_object({}) do |user_id,memo|
        memo[user_id] = pearson_z.rmse user_id, @threshold
      end,
      #'SVD full' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = svd_full.rmse user_id, @threshold
      #end,
      #'SVD Z-score' => all_user_ids.each_with_object({}) do |user_id,memo|
        #memo[user_id] = svd_partial.rmse user_id, @threshold
      #end
    }
    @metrics.each {|metric, data| data.select! {|k,v| !v.nan? } }

    @users = [User.new(nickname: "Статтистика (#{all_user_ids.size} человек)")] + @users
    @users[0].id = -1
  end
end
