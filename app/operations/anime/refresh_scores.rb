class Anime::RefreshScores
  method_object :entry, :global_average

  def call
    @entry.update(
      score_2: Animes::WeightedScore.call(
        number_of_scores: user_rates_scope.size,
        average_user_score: user_rates_scope.average(:score),
        global_average: @global_average
      )
    )
  end

private

  def user_rates_scope
    UserRate
      .joins('JOIN users ON users.id = user_rates.user_id')
      .where(target_id: @entry.id, target_type: @entry.class.base_class.name)
      .where('score > 0')
      .where.not(user_id: User.excluded_from_statistics)
  end
end
