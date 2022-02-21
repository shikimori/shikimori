class Anime::RefreshScores
  class << self
    MIN_RATES = 30

    def call(entry_class, entry_id, global_average)
      rates = UserRate.where(target_id: entry_id, target_type: entry_class.to_s).where('score > 0')

      unless rates.length < MIN_RATES
        average = rates.average(:score) / 10
        number_of_scores = rates.length

        weighted_score = ((number_of_scores.to_f / (number_of_scores + MIN_RATES)) * average) +
                         ((MIN_RATES.to_f / (number_of_scores + MIN_RATES)) * global_average)

        entry = entry_class.find entry_id
        entry.update(score_2: weighted_score.round(2))
      end
    end
  end
end
