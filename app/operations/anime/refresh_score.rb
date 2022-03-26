class Anime::RefreshScore
  method_object :entry, :global_average

  def call
    if @entry.status == 'anons'
      @entry.update score_2: 0 unless @entry.score_2.zero?
    else
      new_score = Animes::WeightedScore.call(
        number_of_scores: user_rates_scope.size,
        average_user_score: user_rates_scope.average(:score),
        global_average: @global_average
      )
      @entry.update score_2: new_score unless @entry.score_2 == new_score
    end
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
