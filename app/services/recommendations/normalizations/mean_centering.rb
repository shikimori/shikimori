class Recommendations::Normalizations::MeanCentering < Recommendations::Normalizations::NormalizationBase
  def normalize ratings, user_id
    mean_score = mean ratings.values, user_id

    ratings.each_with_object({}) do |(target_id, score), memo|
      memo[target_id] = score - mean_score
    end
  end

  def score score, user_id, ratings
    score - mean(ratings.values, user_id)
  end

  def restore_score normalized_score, user_id, ratings
    normalized_score + mean(ratings.values, user_id)
  end

  # mean, используемый для приведения реокмендованной оценке к 10 бальной шкале
  def restorable_mean scores
    _mean scores
  end
end
