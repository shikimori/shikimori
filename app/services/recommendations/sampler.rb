class Recommendations::Sampler
  Planned = UserRateStatus.get UserRateStatus::Planned
  Dropped = UserRateStatus.get UserRateStatus::Dropped

  # сколько максимум делать рекомендаций
  MaxRecommendations = 500
  # сколько минимум должно быть голосов, чтобы можно было попытаться выдать рекомендации
  MinimumScores = 20

  def initialize(klass, metric, rates_fetcher, normalization, user_cache_key)
    @klass = klass
    @metric = metric
    @rates_fetcher = rates_fetcher
    @normalization = normalization

    @user_cache_key = user_cache_key

    @metric.klass = @klass
    @metric.normalization = @normalization
    @metric.user_cache_key = @user_cache_key
  end

  def rmse(user_id, threshold)
    data = rankings(user_id, threshold, false)

    rates = user_rates(user_id).map do |target_id, score|
      {
        target_id: target_id,
        gain_score: score,
        score: data[target_id]
      }
    end.select {|v| v[:score].present? }

    Math.sqrt(rates.map {|v| (v[:score] - v[:gain_score])**2}.sum * 1.0 / rates.size)
  end

  def recommend(user_id, threshold)
    #data = rankings(user_id, threshold, true)#.select {|k,v| !v.nan? }
    data = rankings(user_id, threshold, true)
        .select {|k,v| !v.nan? }
        .sort_by {|k,v| -v }
        .take(MaxRecommendations)

    Hash[data]
  end

  def user_rates(user_id)
    @user_rates ||= Rails.cache.fetch "#{@user_cache_key}_#{@normalization.class}_user_rates", expires_in: 2.weeks do
      fetcher = @rates_fetcher.clone
      fetcher.user_ids = [user_id]
      fetcher.user_cache_key = @user_cache_key
      z = fetcher.fetch(@normalization)[user_id]
    end
  end

private
  def rankings(user_id, threshold, without_user_rates)
    return {} if user_rates(user_id).nil?
    @metric.learn user_id, user_rates(user_id), @rates_fetcher.fetch(@normalization)
    @metric.predict user_id, threshold, without_user_rates
  end
end
