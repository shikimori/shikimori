class CompatibilityService
  METRIC = Recommendations::Metrics::Pearson
  NORMALIZATION = Recommendations::Normalizations::ZScore

  attr_accessor :rates_fetcher, :user_2

  def self.fetch user1, user2
    Rails.cache.fetch("compatibility_#{user1.cache_key}_#{user2.cache_key}_#{METRIC}_#{NORMALIZATION}") do
      {
        anime: new(user1, user2, Anime).fetch,
        manga: new(user1, user2, Manga).fetch
      }
    end
  end

  def initialize user1, user2, klass
    @user_1 = user1
    @user_2 = user2
    @klass = klass

    #@normalization = Recommendations::Normalizations::None.new
    #@normalization = Recommendations::Normalizations::ConstCut.new
    @normalization = NORMALIZATION.new

    @rates_fetcher = Recommendations::RatesFetcher.new @klass
    @rates_fetcher.user_cache_key = [@user_1.cache_key, @user_2.cache_key].sort.join(',')
    @rates_fetcher.user_ids = [@user_1.id, @user_2.id]

    @metric = METRIC.new
    @metric.klass = @klass
    @metric.normalization = @normalization
  end

  def fetch user_2 = nil
    user_2 ||= @user_2

    normalize @metric.compare(
      @user_1.id,
      user_rates(@user_1),
      user_2.id,
      user_rates(user_2)
    )
  end

  def normalize compatibility
    if compatibility.kind_of?(Complex)# || compatibility <= 0
      nil
    else
      ("%.1f" % [100.0 * compatibility]).to_f
      #("%.1f" % [100.0 * [compatibility, 0].max]).to_f
    end
  end

  def user_rates user
    @rates_fetcher.fetch(@normalization)[user.id] || {}
  end
end
