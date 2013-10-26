class Recommendations::Normalizations::None < Recommendations::Normalizations::NormalizationBase
  def normalize(ratings, user_id)
  end

  def score(score, user_id, ratings)
    score
  end

  def total_mean(scores, user_id)
    0
  end
end
