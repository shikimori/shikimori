class Recommendations::Normalizations::MeanCentering < Recommendations::Normalizations::NormalizationBase
  def normalize(ratings, user_id)
    mean_score = mean ratings.values, user_id

    ratings.each do |target_id, score|
      ratings[target_id] = score - mean_score
    end
  end

  def score(score, user_id, ratings)
    score - mean(ratings.values, user_id)
  end

  def total_mean(scores, user_id)
    mean scores, user_id
  end
end
