class Recommendations::Metrics::AvgScore < Recommendations::Metrics::MetricBase
  def predict user_id, threshold, without_user_rates
    votes = {}
    totals = {}

    @all_rates_normalized.each do |sampler_id, scores|
      scores.each do |id,score|
        next if score.try(:nan?)

        votes[id] = (votes[id] || 0) + 1
        totals[id] = (totals[id] || 0) + score
      end
    end

    votes.each_with_object({}) do |(id, votes_num), memo|
      memo[id] = totals[id] / votes_num
    end
  end
end
