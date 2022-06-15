class RecommendationsWorker # rubocop:disable ClassLength
  include Sidekiq::Worker

  sidekiq_options(
    lock: :until_executed,
    lock_args: ->(args) { args.first },
    queue: :cpu_intensive,
    retry: false
  )

  def perform( # rubocop:disable ParameterLists
    user_id,
    type,
    metric,
    threshold,
    cache_key,
    user_list_cache_key
  )
    Rails.cache.fetch cache_key, expires_in: 2.weeks do
      fetch user_id, type.constantize, metric, threshold, user_list_cache_key
    end
  end

private

  def fetch user_id, klass, metric, threshold, user_list_cache_key
    sampler = send metric.to_sym, klass, user_list_cache_key
    sampler.recommend user_id, threshold
  end

  def rates_fetcher klass
    Recommendations::RatesFetcher.new klass
  end

  def norm_none
    Recommendations::Normalizations::None.new
  end

  def norm_mean_centering
    Recommendations::Normalizations::MeanCentering.new
  end

  def norm_z_score
    Recommendations::Normalizations::ZScore.new
  end

  def perason klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::Pearson.new,
      rates_fetcher(klass),
      norm_none,
      user_list_cache_key
    )
  end

  def pearson_z klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::Pearson.new,
      rates_fetcher(klass),
      norm_z_score,
      user_list_cache_key
    )
  end

  def euclid klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::Euclid.new,
      rates_fetcher(klass),
      norm_none,
      user_list_cache_key
    )
  end

  def euclid_z klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::Euclid.new,
      rates_fetcher(klass),
      norm_z_score,
      user_list_cache_key
    )
  end

  def svd klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::SvdMetric.new(
        Svd.where(normalization: :none).last!
      ),
      rates_fetcher(klass),
      norm_none,
      user_list_cache_key
    )
  end

  def svd_mean klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::SvdMetric.new(
        Svd.where(normalization: :norm_mean_centering).last!
      ),
      rates_fetcher(klass),
      norm_mean_centering,
      user_list_cache_key
    )
  end

  def svd_z klass, user_list_cache_key
    Recommendations::Sampler.new(
      klass,
      Recommendations::Metrics::SvdMetric.new(
        Svd.where(normalization: :norm_z_score).last!
      ),
      rates_fetcher(klass),
      norm_z_score,
      user_list_cache_key
    )
  end
end
