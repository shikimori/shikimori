class CompatibilityService
  def self.fetch user1, user2
    Rails.cache.fetch("compatibility_#{user1.cache_key}_#{user2.cache_key}_#{@metric.class}_#{@normalization.class}") do
      {
        anime: new(user1, user2, Anime).fetch,
        manga: new(user1, user2, Manga).fetch
      }
    end
  end

  def initialize user1, user2, klass
    @user1 = user1
    @user2 = user2
    @klass = klass

    #@normalization = Recommendations::Normalizations::None.new
    #@normalization = Recommendations::Normalizations::ConstCut.new
    @normalization = Recommendations::Normalizations::ZScore.new
    @rates_fetcher = Recommendations::RatesFetcher.new @klass

    @metric = Recommendations::Metrics::Pearson.new
    @metric.klass = @klass
    @metric.normalization = @normalization
  end

  def fetch
    normalize @metric.compare(@user1.id, user_rates(@user1) || {}, @user2.id, user_rates(@user2) || {})
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
    @rates_fetcher.user_cache_key = user.cache_key
    @rates_fetcher.user_ids = [user.id]
    @rates_fetcher.fetch(@normalization)[user.id] || {}
  end
end
