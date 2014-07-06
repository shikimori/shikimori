class Recommendations::Metrics::SvdMetric < Recommendations::Metrics::MetricBase
  def initialize(svd)
    @svd = svd
  end

  def compare(user_id, user_rates, sampler_id, sampler_rates)
    return 0 unless user_rates && sampler_rates

    if @svd.user_ids.include?(sampler_id)
      ranks = Rails.cache.fetch "svd_rank_#{@svd.id}_#{user_id}_#{user_rates.size}", expires_in: 2.weeks do
        @svd.rank(user_rates)
      end
      ranks[sampler_id] || 0

    else
      0
    end
  end

  def cache_key(*args)
    "#{super(*args)}_svd##{@svd.id}"
  end
end
