class Recommendations::Metrics::Pearson < Recommendations::Metrics::MetricBase
  # def ignore_similarity? similarity
    # super || similarity <= 0
  # end

  def compare _user_id, user_rates, _sampler_id, sampler_rates
    return 0 unless user_rates && sampler_rates
    shared_ids = user_rates.keys & sampler_rates.keys
    return 0 if shared_ids.empty? || shared_ids.size < MINIMUM_SHARED

    sum1 = sum2 = sum1Sq = sum2Sq = pSum = 0.0

    shared_ids.each do |id|
      prefs1_item = user_rates[id] || 0.0
      prefs2_item = sampler_rates[id] || 0.0

      sum1   += prefs1_item
      sum2   += prefs2_item
      sum1Sq += prefs1_item**2
      sum2Sq += prefs2_item**2
      pSum   += prefs2_item * prefs1_item
    end

    num = pSum - ((sum1 * sum2) / shared_ids.size)

    metric = (sum1Sq - (sum1**2) / shared_ids.size) *
      (sum2Sq - (sum2**2) / shared_ids.size)
    return 0 if metric <= 0

    den = Math.sqrt(metric)

    num / den
  end
end
