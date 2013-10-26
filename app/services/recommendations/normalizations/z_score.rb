class Recommendations::Normalizations::ZScore < Recommendations::Normalizations::MeanCentering
  def normalize(ratings, user_id)
    super ratings, user_id

    deviation = sigma ratings.values, user_id

    ratings.each do |target_id, score|
      ratings[target_id] = ratings[target_id] / deviation
    end
  end

  def score(score, user_id, ratings)
    super(score, user_id, ratings) / sigma(ratings.values, user_id)
  end

  def total_sigma(scores, user_id)
    sigma scores, user_id
  end
end
