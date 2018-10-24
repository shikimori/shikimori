class Animes::UserRatesStatisticsQuery
  pattr_initialize :entry, :user

  def friend_rates
    @entry.rates
      .where(user_id: @user.friend_links.pluck(:dst_id))
      .includes(:user)
      .sort_by(&:updated_at)
      .reverse
  end

  # def recent_rates limit
    # @entry.rates
      # .includes(:user)
      # .order(updated_at: :desc)
      # .limit(limit)
      # .to_a
  # end

  def statuses_stats
    anticheat_scope
      .group(:status)
      .count
      .sort_by(&:first)
      .each_with_object({}) do |(status, count), memo|
        fixed_status = status == 'rewatching' ? 'completed' : status
        memo[fixed_status] ||= 0
        memo[fixed_status] += count
      end
  end

  def scores_stats
    Hash[
      anticheat_scope
        .group(:score)
        .count
        .sort_by(&:first)
        .reverse
        .reject { |k, _v| k.zero? }
    ]
  end

private

  def anticheat_scope
    @entry.rates.where.not(user_id: User.cheat_bot)
  end
end
