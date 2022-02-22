class Anime::RefreshScores
  method_object :entry, :global_average

  MIN_RATES = 30

  def call
    rates = UserRate
      .joins('JOIN users ON users.id = user_rates.user_id')
      .where(target_id: entry.id, target_type: entry.class.to_s)
      .where('score > 0')
      .where.not(user_id: User.excluded_from_statistics)

    unless rates.length < MIN_RATES
      average = rates.average(:score) / 10
      number_of_scores = rates.length

      weighted_score = ((number_of_scores.to_f / (number_of_scores + MIN_RATES)) * average) +
                       ((MIN_RATES.to_f / (number_of_scores + MIN_RATES)) * global_average)

      entry.update(score_2: weighted_score.round(2))
    end
  end
end
