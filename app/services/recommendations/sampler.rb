class Recommendations::Sampler
  # сколько максимум делать рекомендаций
  MAX_RECOMMENDATIONS = 500
  # сколько минимум должно быть голосов, чтобы можно было попытаться выдать рекомендации
  MINIMUM_SCORES = 20

  def initialize klass, metric, rates_fetcher, normalization, user_cache_key
    @klass = klass
    @metric = metric
    @rates_fetcher = rates_fetcher
    @normalization = normalization

    @no_normalization = Recommendations::Normalizations::None.new

    @user_cache_key = user_cache_key

    @metric.klass = @klass
    @metric.normalization = @normalization
    @metric.user_cache_key = @user_cache_key
  end

  def rmse user_id, threshold
    NamedLogger.recommendations.info(
      <<-LOG.squish
        calculating #{@metric.class.name.sub(/.*:/, '')}
        #{@normalization.class.name.sub(/.*:/, '')} RMSE
        for user[#{user_id}]".light_red
      LOG
    )

    scores_predicted = rankings(user_id, threshold, false)
    scores_gain = user_rates(user_id, @no_normalization)
    # scores_normalized = user_rates(user_id, @no_normalization)

    rates = scores_gain
      .map do |target_id, _|
        next unless scores_predicted[target_id]

        # puts "#{target_id}: #{scores_gain[target_id].round(1)} -> #{scores_predicted[target_id].round(1)} (#{scores_normalized[target_id].round(1)})"
        {
          target_id: target_id,
          gain_score: scores_gain[target_id],
          predicted_score: scores_predicted[target_id]
        }
      end
      .compact
      # .select {|v| v[:predicted_score] > 0 && v[:predicted_score] < 10 }

    [
      # Math.sqrt(rates.map {|v| (v[:normalized_score] - v[:gain_normalized_score])**2}.sum * 1.0 / rates.size),
      0,
      Math.sqrt(
        rates.map { |v| (v[:predicted_score] - v[:gain_score])**2 }.sum *
          1.0 / rates.size
      )
    ]
  end

  def recommend user_id, threshold
    data = rankings(user_id, threshold, true)
      .reject { |_k, v| v.nan? }
      .sort_by { |_k, v| -v }
      .take(MAX_RECOMMENDATIONS)

    Hash[data]
  end

  def user_rates user_id, normalization
    cache_key = [:sampler, :v2, @user_cache_key, normalization.class].join('_')

    # @user_rates ||= {}
    # @user_rates[cache_key.join('_')] ||= PgCache.fetch(cache_key, expires_in: 2.weeks, serializer: MessagePack) do
    #   if Rails.env.development? # в девелопмента можно грузить всё из кеша
    #     @rates_fetcher.fetch(normalization)
    #   else # а на продакшене текущий список пользователя и список закешированный будет отличаться
    #     fetcher = @rates_fetcher.clone
    #     fetcher.user_ids = [user_id]
    #     fetcher.user_cache_key = @user_cache_key
    #     fetcher.fetch(@normalization)[user_id]
    #   end
    # end

    # if Rails.env.development? # в девелопмента можно грузить всё из кеша
    #   @user_rates[cache_key.join('_')][user_id] || {}
    # else
    #   @user_rates[cache_key.join('_')] || {}
    # end

    @user_rates ||= {}
    @user_rates[cache_key] ||=
      PgCache.fetch(cache_key, expires_in: 2.weeks, serializer: MessagePack) do
        fetcher = @rates_fetcher.clone
        fetcher.user_ids = [user_id]
        fetcher.user_cache_key = @user_cache_key
        fetcher.fetch(@normalization)[user_id]
      end
  end

private

  def rankings user_id, threshold, without_user_rates
    # return {} if user_rates(user_id, @normalization).nil?
    # raise 'invalid data or changed user list. try Rails.cache.clear' if user_rates(user_id, @normalization).first.second != @rates_fetcher.fetch(@normalization)[user_id].first.second

    @metric.learn(
      user_id,
      user_rates(user_id, @no_normalization),
      user_rates(user_id, @normalization),
      @rates_fetcher.fetch(@normalization)
    )
    @metric.predict user_id, threshold, without_user_rates
  end
end
