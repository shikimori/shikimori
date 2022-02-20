class Anime::UpdateScore
  class << self
    # score_2 - just an average score
    # score 3 - MAL wighted formula
    # score 4 - same as 3 without users with bad dispersion and low rates number
    # score 5 - same as 4 with user scores normalized

    ANIME_MIN_RATES = 30     # минимум оценок для определения рейтинга аниме
    MANGA_MIN_RATES = 20     # минимум оценок для определения рейтинга манги

    USER_MIN_RATES = 2       # минимум оценок у пользователя чтобы учитывать его при подсчёте рейтинга
    MIN_DISPERSION = 1.0     # минимальный корень СКО оценок пользователя чтобы учитывать его при подсчёте рейтинга
    MED_AVG_DELTA = 3        # нормализуем распределения более менее похожие на нормальное по медиане
    CENTER_SCORE = 7.5       # центр для смещения
    MAX_OFFSET = 1.5         # максимальная величина смещения

    def call
      update_score_2_and_3(Anime)
      update_score_2_and_3(Manga)

      update_score_4(Anime)
      update_score_4(Manga)

      update_score_5(Anime)
      update_score_5(Manga)
    end

    def update_score_2_and_3(entry_class)
      entry_class.find_each(batch_size: 1000) do |entry|
        rates = UserRate.where(target_id: entry.id, target_type: entry_class.to_s).where("score > 0")
        next unless rates.length > 0

        average_score = average(rates) / 10
        number_of_scores = rates.length

        weighted_score = (number_of_scores.to_f / (number_of_scores + ANIME_MIN_RATES)) * average_score +
                         (ANIME_MIN_RATES.to_f / (number_of_scores + ANIME_MIN_RATES)) * global_average_score(entry_class)

        entry.update(
          score_2: rates.length > ANIME_MIN_RATES ? average_score.round(2) : 0.0,
          score_3: rates.length > ANIME_MIN_RATES ? weighted_score.round(2) : 0.0
        )
      end
    end

    def update_score_4(entry_class)
      temp_results = {}

      User.find_each(batch_size: 1000) do |user|
        user_rates = UserRate.where(user_id: user.id).where(target_type: entry_class.to_s).where("score > 0")
        next if user_rates.length < USER_MIN_RATES
        next if dispersion(user_rates) < MIN_DISPERSION

        user_rates.each do |rate|
          update_tmp(temp_results, rate)
        end
      end

      update_entries_from_tmp(temp_results, entry_class, 'score_4') if temp_results.length > 0
    end

    def update_score_5(entry_class)
      temp_results = {}

      User.find_each(batch_size: 1000) do |user|
        user_rates = UserRate.where(user_id: user.id).where(target_type: entry_class.to_s).where("score > 0")
        next if user_rates.length < USER_MIN_RATES
        next if dispersion(user_rates) < MIN_DISPERSION

        normalize(user_rates).each do |rate|
          update_tmp(temp_results, rate)
        end
      end

      update_entries_from_tmp(temp_results, entry_class, 'score_5') if temp_results.length > 0
    end

    def update_tmp(temp_results, rate)
      temp_rate_info = temp_results[rate.target_id]
      if temp_rate_info.present?
        temp_rate_info[:sum] += rate.score
        temp_rate_info[:count] += 1
      else
        temp_results[rate.target_id] = {
          sum: rate.score,
          count: 1
        }
      end
    end

    def update_entries_from_tmp(temp_results, entry_class, kind)
      global_average = 0
      temp_results.each { |temp_info| global_average += temp_info[1][:sum] / temp_info[1][:count] }
      global_average = global_average / temp_results.length

      temp_results.each do |temp_info|
        if temp_info[1][:count] > ANIME_MIN_RATES
          average_score = temp_info[1][:sum].to_f / temp_info[1][:count]

          weighted_score = (temp_info[1][:count].to_f / (temp_info[1][:count] + ANIME_MIN_RATES)) * average_score +
                       (ANIME_MIN_RATES.to_f / (temp_info[1][:count] + ANIME_MIN_RATES)) * global_average

          puts weighted_score

          case kind
          when 'score_4'
            entry_class.find(temp_info[0]).update(score_4: weighted_score.round(2))
          when 'score_5'
            entry_class.find(temp_info[0]).update(score_5: weighted_score.round(2))
          end
        end
      end
    end

    def normalize(user_rates)
      average = average(user_rates)
      median = median(user_rates)

      if average - median < MED_AVG_DELTA
        offset_length = (median - CENTER_SCORE).abs
        offset_length = MAX_OFFSET if offset_length > MAX_OFFSET

        if median > CENTER_SCORE
          user_rates.each { |rate| rate.score -= offset_length }
        else
          user_rates.each { |rate| rate.score += offset_length }
        end
      end

      user_rates.map do |rate|
        rate.score = 10 if rate.score > 10
        rate.score = 0 if rate.score < 0
      end

      return user_rates
    end

    def average(user_rates)
      average = 0
      user_rates.each { |rate| average += rate.score }
      average.to_f / user_rates.length
    end

    def median(user_rates)
      scores = user_rates.pluck(:score)
      return nil if scores.empty?
      sorted = scores.sort
      len = sorted.length
      (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

    def dispersion(user_rates)
      dispersion_sum = 0
      user_rates.each { |rate| dispersion_sum += (rate.score - average(user_rates)) ** 2 }
      Math.sqrt(dispersion_sum.to_f / (user_rates.length - 1))
    end

    # to cache
    def global_average_score(entry_class)
      # 0.77
      UserRate.where(target_type: entry_class.to_s).where("score > 0").average(:score) / 10
    end

  end
end
