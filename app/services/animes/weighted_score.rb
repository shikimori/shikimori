class Animes::WeightedScore
  method_object %i[number_of_scores average_user_score global_average]

  MIN_SCORES = 30

  def call
    return 0 if @number_of_scores < MIN_SCORES

    (
      ((@number_of_scores.to_f / (@number_of_scores + MIN_SCORES)) * @average_user_score) +
        ((MIN_SCORES.to_f / (@number_of_scores + MIN_SCORES)) * @global_average)
    ).round 2
  end
end
