class RecommendationsJob < Struct.new(:user_id, :klass, :metric, :threshold, :cache_key, :user_list_cache_key)
  def perform
    Rails.cache.fetch cache_key, expires_in: 2.weeks do
      fetch
    end
  end

private
  def fetch
    rates_fetcher = Recommendations::RatesFetcher.new klass

    no_norm = Recommendations::Normalizations::None.new
    mean_centering = Recommendations::Normalizations::MeanCentering.new
    z_score = Recommendations::Normalizations::ZScore.new

    sampler = case metric
      when 'pearson'
        Recommendations::Sampler.new klass, Recommendations::Metrics::Pearson.new, rates_fetcher, no_norm, user_list_cache_key

      when 'pearson_mean'
        Recommendations::Sampler.new klass, Recommendations::Metrics::Pearson.new, rates_fetcher, mean_centering, user_list_cache_key

      when 'pearson_z'
        Recommendations::Sampler.new klass, Recommendations::Metrics::Pearson.new, rates_fetcher, z_score, user_list_cache_key

      when 'euclid'
        Recommendations::Sampler.new klass, Recommendations::Metrics::Euclid.new, rates_fetcher, no_norm, user_list_cache_key

      when 'svd'
        Recommendations::Sampler.new klass, Recommendations::Metrics::Svd.new(Svd.partial), rates_fetcher, z_score, user_list_cache_key

      #when 'svd_partial'
        #Recommendations::Sampler.new klass, Recommendations::Metrics::Svd.new(Svd.partial), rates_fetcher, no_norm, user_list_cache_key

      #when 'svd_full'
        #Recommendations::Sampler.new klass, Recommendations::Metrics::Svd.new(Svd.full), rates_fetcher, z_score, user_list_cache_key

      else
        raise ArgumentError, "unknown metric: #{metric}"
    end

    sampler.recommend user_id, threshold
  end

  def klass
    super.constantize
  end
end
