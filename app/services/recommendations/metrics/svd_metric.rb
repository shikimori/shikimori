class Recommendations::Metrics::SvdMetric < Recommendations::Metrics::MetricBase
  def initialize svd
    @svd = svd
    @ranks = {}
  end

  def compare user_id, user_rates, sampler_id, sampler_rates
    if @svd.user_ids.include?(sampler_id)
      rank_key = "svd_rank_#{@svd.id}_#{user_id}_#{user_rates.size}"
      @ranks[rank_key] ||= Rails.cache.fetch(rank_key, expires_in: 2.weeks) { @svd.rank(user_rates) }
      @ranks[rank_key][sampler_id]
    end || Float::NAN
  end

  def cache_key *args
    super(*args) + [:svd, @svd.id]
  end
end
