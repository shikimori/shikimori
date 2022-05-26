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
    @entry.stats.scores_stats.inject(0) { |sum, stat| sum + stat['value'] }
  end

  def average_user_score
    @entry.stats.scores_stats.inject(0) do |sum, stat|
      sum + stat['key'].to_f * stat['value'] / number_of_scores
    end
  end

=begin
  def user_rates_scope
    # filter_options.inject(all_user_rates_scope) do |scope, option|
    #   filter_rates_by option, scope
    # end
    all_user_rates_scope
  end

  def all_user_rates_scope
    UserRate
      .joins('JOIN users ON users.id = user_rates.user_id')
      .where(target_id: @entry.id, target_type: @entry.class.base_class.name)
      .where('score > 0')
      .where.not(user_id: User.excluded_from_statistics)
  end

  def filter_options
    @entry.options.filter { |option| option.include? 'score_filter_' }
  end

  def filter_rates_by option, scope
    score_to_filter = option.gsub('score_filter_', '').split('_').first.to_i
    filter_percentage = option.gsub('score_filter_', '').split('_').second.to_i

    rates_to_filter = scope.where(score: score_to_filter)

    filtered_rates_count = (rates_to_filter.count * filter_percentage / 100).to_i
    filtered_rates = rates_to_filter.limit(filtered_rates_count)

    scope.where.not(id: filtered_rates.select(:id)) if filtered_rates.any?
  end
=end

end
