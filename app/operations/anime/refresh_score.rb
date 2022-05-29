class Anime::RefreshScore
  method_object :entry, :global_average

  def call
    new_score = @entry.anons? ?
      0 :
      Animes::WeightedScore.call(
        number_of_scores: number_of_scores,
        average_user_score: average_user_score,
        global_average: @global_average
      )

    @entry.update score_2: new_score unless @entry.score_2 == new_score
  end

private

  def number_of_scores
    @entry.stats.scores_stats.sum { |stat| stat['value'] }
  end

  def average_user_score
    @entry.stats.scores_stats.sum do |stat|
      stat['key'].to_f * stat['value'] / number_of_scores
    end
  end
end
