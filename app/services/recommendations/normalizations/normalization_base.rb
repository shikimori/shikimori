class Recommendations::Normalizations::NormalizationBase
  def initialize
    @means = {}
    @sigmas = {}
  end

  def total_sigma(scores, user_id)
    1.0
  end

private
  def mean(scores, user_id)
    @means[user_id] ||= scores.sum * 1.0 / scores.size
  end

  def sigma(scores, user_id)
    @sigmas[user_id] ||= begin
      mean_score = mean scores, user_id

      Math.sqrt(scores.sum {|v| (v - mean_score) ** 2 } / scores.size)
    end
  end
end
