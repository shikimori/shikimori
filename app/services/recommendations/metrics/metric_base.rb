class Recommendations::Metrics::MetricBase
  # сколько минимум должно быть пересекающихся голосов, чтобы можно было подсчитать похожесть
  MinimumShared = 7

  attr_accessor :klass
  attr_accessor :normalization
  attr_accessor :user_cache_key

  def learn(user_id, user_rates, all_rates)
    @all_rates = all_rates
    @user_rates = user_rates
  end

  def predict(user_id, threshold, without_user_rates)
    totals, votes, similarities_sum = Rails.cache.fetch cache_key(user_id, without_user_rates), expires_in: 2.weeks do
      calculate user_id, threshold, without_user_rates
    end

    # normalized list of items
    totals.each_with_object({}) do |v,memo|
      id, total = v.first, v.second

      if votes[id] > threshold
        memo[id] = @normalization.total_mean(@user_rates.values, user_id) +
          @normalization.total_sigma(@user_rates.values, user_id) * total / similarities_sum[id]
      end
    end
  end

private
  def calculate(user_id, threshold, without_user_rates)
    totals = {}
    votes = {}
    similarities_sum = {}

    @all_rates.each do |sampler_id, scores|
      # себя не надо учитывать
      next if without_user_rates && sampler_id == user_id

      # получение похожести
      similarity = compare user_id, @user_rates, sampler_id, @all_rates[sampler_id]

      # нулевую похожесть не учитываем (отрицательную так же - Pearson)
      if similarity.kind_of?(Complex)# || similarity <= 0
        #Rails.logger.info "Complex similarity user_id: #{user_id} sampler_id: #{sampler_id}" if similarity.kind_of?(Complex)
        next
      end

      scores.each do |id,score|
        # рекомендовать будем только то, чего у пользователя не в списке
        next if without_user_rates && @user_rates.include?(id)

        # счётчик голосов
        votes[id] = (votes[id] || 0) + 1

        # similarity * score
        totals[id] = (totals[id] || 0) + similarity * @normalization.score(score, sampler_id, scores)

        # sum of similarities
        similarities_sum[id] = (similarities_sum[id] || 0) + similarity
      end
    end

    [totals, votes, similarities_sum]
  end

  def cache_key(user_id, without_user_rates)
    "recommendations_metric_#{self.class}_#{klass}_#{@normalization.class}_#{user_id}_#{without_user_rates}_#{user_cache_key}"
  end
end
