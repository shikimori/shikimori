class Recommendations::Normalizations::None < Recommendations::Normalizations::NormalizationBase
  def normalize ratings, user_id
    ratings.clone
  end

  def score score, user_id, ratings
    score
  end

  def restore_score score, user_id, ratings
    score
  end

  def total_mean scores, user_id
    # так надо для алгоритма
    0
  end
end
