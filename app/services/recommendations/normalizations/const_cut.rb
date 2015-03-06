class Recommendations::Normalizations::ConstCut < Recommendations::Normalizations::None
  MinimalScore = 5

  def normalize ratings, user_id
    ratings.each_with_object({}) do |(target_id, score), memo|
      memo[target_id] = score < MinimalScore ? MinimalScore : score
    end
  end
end
