class CompatibilityService
  METRIC = Recommendations::Metrics::Pearson
  NORMALIZATION = Recommendations::Normalizations::ZScore

  attr_accessor :rates_fetcher, :user_2

  def self.fetch user_1, user_2
    cache_key = [:compatibility, user_1, user_2, METRIC, NORMALIZATION]

    Rails.cache.fetch cache_key do
      {
        anime: new(user_1, user_2, Anime).fetch,
        manga: new(user_1, user_2, Manga).fetch
      }
    end
  end

  def initialize user_1, user_2, klass
    @user_1 = user_1
    @user_2 = user_2
    @klass = klass

    # @normalization = Recommendations::Normalizations::None.new
    # @normalization = Recommendations::Normalizations::ConstCut.new
    @normalization = NORMALIZATION.new

    @metric = METRIC.new
    @metric.klass = @klass
    @metric.normalization = @normalization
  end

  def fetch user_2 = nil, rates_fetcher = nil
    user_2 ||= @user_2

    normalize @metric.compare(
      @user_1.id,
      user_rates(@user_1, rates_fetcher),
      user_2.id,
      user_rates(user_2, rates_fetcher)
    )
  end

  def normalize compatibility
    if compatibility.is_a?(Complex) # || compatibility <= 0
      nil
    else
      format('%.1f', 100.0 * compatibility).to_f
      # ("%.1f" % [100.0 * [compatibility, 0].max]).to_f
    end
  end

  def user_rates user, rates_fetcher
    unless rates_fetcher
      rates_fetcher = Recommendations::RatesFetcher.new(@klass)
      rates_fetcher.user_ids = [user.id]
      rates_fetcher.user_cache_key = user.cache_key_with_version
    end

    rates_fetcher.fetch(@normalization)[user.id] || {}
  end
end
