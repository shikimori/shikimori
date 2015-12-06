class RecommendationsWorker
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    unique_args: -> (args) { args.first },
    queue: :cpu_intensive,
    retry: false
  )

  def perform user_id, type, metric, threshold, cache_key, user_list_cache_key
    Rails.cache.fetch cache_key, expires_in: 2.weeks do
      fetch user_id, type.constantize, metric, threshold, user_list_cache_key
    end
  end

private

  def fetch user_id, klass, metric, threshold, user_list_cache_key
    rates_fetcher = Recommendations::RatesFetcher.new klass

    no_norm = Recommendations::Normalizations::None.new
    mean_centering = Recommendations::Normalizations::MeanCentering.new
    z_score = Recommendations::Normalizations::ZScore.new

    sampler = case metric.to_sym
      when :pearson
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::Pearson.new, rates_fetcher, no_norm, user_list_cache_key

      #when :pearson_mean
        #Recommendations::Sampler.new klass,
          #Recommendations::Metrics::Pearson.new, rates_fetcher, mean_centering, user_list_cache_key

      when :pearson_z
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::Pearson.new, rates_fetcher, z_score, user_list_cache_key

      when :euclid
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::Euclid.new, rates_fetcher, no_norm, user_list_cache_key

      when :euclid_z
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::Euclid.new, rates_fetcher, z_score, user_list_cache_key

      when :svd
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :none).last!),
          rates_fetcher, no_norm, user_list_cache_key

      when :svd_mean
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :mean_centering).last!),
          rates_fetcher, mean_centering, user_list_cache_key

      when :svd_z
        Recommendations::Sampler.new klass,
          Recommendations::Metrics::SvdMetric.new(Svd.where(normalization: :z_score).last!),
          rates_fetcher, z_score, user_list_cache_key

      else
        raise ArgumentError, "unknown metric: #{metric}"
    end

    sampler.recommend user_id, threshold
  end
end
