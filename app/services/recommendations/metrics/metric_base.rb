class Recommendations::Metrics::MetricBase
  # сколько минимум должно быть пересекающихся голосов, чтобы можно было подсчитать похожесть
  MINIMUM_SHARED = 7

  attr_accessor :klass
  attr_accessor :normalization
  attr_accessor :user_cache_key

  def learn user_id, user_rates_gain, user_rates_normalized, all_rates_normalized
    @user_rates_gain = user_rates_gain
    @user_rates_normalized = user_rates_normalized
    @all_rates_normalized = all_rates_normalized
  end

  def predict user_id, threshold, without_user_rates
    totals, votes, similarities_sum = Rails.cache.fetch cache_key(user_id, without_user_rates), expires_in: 2.weeks do
      calculate user_id, threshold, without_user_rates
    end

    restorable_mean = @normalization.restorable_mean @user_rates_gain.values
    restorable_sigma = @normalization.restorable_sigma @user_rates_gain.values

    # normalized list of items
    totals.each_with_object({}) do |(item_id, total), memo|
      next if votes[item_id] <= threshold || similarities_sum[item_id].zero?
      memo[item_id] = total / similarities_sum[item_id] * restorable_sigma + restorable_mean
      #puts "#{item_id}: #{memo[item_id]}"
    end
  end

private

  def ignore_similarity? similarity
    similarity.kind_of?(Complex) || similarity.try(:nan?)
  end

  def calculate user_id, threshold, without_user_rates
    totals = {}
    votes = {}
    similarities_sum = {}

    @all_rates_normalized.each do |sampler_id, sampler_scores|
      # себя не надо учитывать
      next if without_user_rates && sampler_id == user_id

      # получение похожести
      similarity = compare user_id, @user_rates_normalized, sampler_id, @all_rates_normalized[sampler_id]

      # нулевую похожесть не учитываем (отрицательную так же - Pearson)
      # с отрицательной может получаться так, что при близких суммах отрицательных и положительных похожестей,
      # нитоговая similarities_sum может оказаться близкой к нулю, что даст очень странную оценку в итоге
      #Rails.logger.info "Complex similarity for #{user_id} x #{sampler_id}" if similarity.kind_of?(Complex)
      #Rails.logger.info "NaN similarity for #{user_id} x #{sampler_id}" if similarity.try(:nan?)
      #Rails.logger.info "#{similarity} similarity for #{user_id} x #{sampler_id}"
      next if ignore_similarity? similarity

      sampler_scores.each do |item_id, score|
        # рекомендовать будем только то, чего у пользователя нет в списке
        next if without_user_rates && @user_rates_normalized.include?(item_id)
        next if score.try(:nan?)

        # счётчик голосов
        votes[item_id] = (votes[item_id] || 0) + 1

        # similarity * score
        totals[item_id] = (totals[item_id] || 0) + similarity * score

        # sum of similarities
        similarities_sum[item_id] = (similarities_sum[item_id] || 0) + similarity

        #binding.pry if sampler_id == 1 && item_id == 4224
        #puts "#{sampler_id}: score [#{score.round 2}]\tsimil [#{similarity.round 2}]" if item_id == 4224
        #puts "#{sampler_id}: score [#{score.round 2} -> #{@all_rates_normalized_gained[sampler_id][item_id]}]\tsimil [#{similarity.round 2}]" if item_id == 4224
      end
    end

    [totals, votes, similarities_sum]
  end

  def cache_key user_id, without_user_rates
    [:recommendations_metric, self.class.name, klass.name, @normalization.class.name, user_id, without_user_rates, user_cache_key]
  end
end
