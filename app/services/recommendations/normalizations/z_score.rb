class Recommendations::Normalizations::ZScore < Recommendations::Normalizations::MeanCentering
  alias_method :mean_ratings, :normalize

  def normalize ratings, user_id
    mean_ratings = mean_ratings(ratings, user_id)
    mean_deviation = sigma(mean_ratings.values, user_id)

    mean_ratings.each_with_object({}) do |(target_id, score), memo|
      memo[target_id] = score / mean_deviation
    end
  end

  def score score, user_id, ratings
    mean_ratings = mean_ratings(ratings, user_id)
    mean_deviation = _sigma(mean_ratings.values)
    mean_score = _mean(ratings.values)

    (score - mean_score) / mean_deviation
  end

  def restore_score normalized_score, user_id, ratings
    mean_ratings = mean_ratings(ratings, user_id)
    mean_deviation = _sigma(mean_ratings.values)
    mean_score = _mean(ratings.values)

    normalized_score * mean_deviation + mean_score
  end

  # mean, используемый для приведения реокмендованной оценке к 10 бальной шкале
  def restorable_mean scores
    _mean scores
  end

  # sigma, используемый для приведения реокмендованной оценке к 10 бальной шкале
  def restorable_sigma scores
    _sigma scores
  end
end
