class Recommendations::Normalizations::ConstCut < Recommendations::Normalizations::None
  MinimalScore = 5

  def normalize(ratings, user_id)
    ratings.each do |target_id, score|
      ratings[target_id] = MinimalScore if score < MinimalScore
    end
  end
end
