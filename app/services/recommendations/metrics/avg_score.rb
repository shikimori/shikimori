class Recommendations::Metrics::AvgScore < Recommendations::Metrics::MetricBase
  def initialize(entries_fetcher)
    @entries_fetcher = entries_fetcher
  end

  def learn(user_id, user_rates, all_rates)
  end

  def predict(user_id, threshold, without_user_rates)
    @entries_fetcher.fetch.each_with_object({}) do |(k,v),memo|
      memo[v.id] = v.score
    end
  end
end
