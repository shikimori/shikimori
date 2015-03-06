class Recommendations::Metrics::Euclid < Recommendations::Metrics::MetricBase
  def compare(user_id, user_rates, sampler_id, sampler_rates)
    return 0 unless user_rates && sampler_rates
    shared_ids = user_rates.keys & sampler_rates.keys
    return 0 if shared_ids.empty? || shared_ids.size < MINIMUM_SHARED

    # сумма квадратов разницы
    sum_of_squares = shared_ids.sum do |id|
      (user_rates[id] - sampler_rates[id])**2
    end

    # высчитывание итогового коэффициента
    1 / (1 + Math.sqrt(sum_of_squares))
  end
end
