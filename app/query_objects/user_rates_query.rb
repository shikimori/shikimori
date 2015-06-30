class UserRatesQuery
  def initialize entry, user
    @entry = entry
    @user = user
  end

  # оценки друзей пользователя
  def friend_rates
    @entry.rates
      .where(user_id: @user.friend_links.pluck(:dst_id))
      .includes(:user)
      .sort_by(&:updated_at)
      .reverse
  end

  # последние изменения от всех пользователей
  def recent_rates limit
    @entry.rates
      .includes(:user)
      .order(updated_at: :desc)
      .limit(limit)
      .to_a
  end

  # статусы пользователей сайта
  def statuses_stats
    Hash[
      @entry.rates
        .group(:status)
        .count
        .sort_by(&:first)
        .select {|k,v| k != UserRate.statuses['rewatching'] }
    ]
  end

  # оценки пользователей сайта
  def scores_stats
    Hash[
      @entry.rates
        .group(:score)
        .count
        .sort_by(&:first)
        .reverse
        .select {|k,v| k != 0 }
    ]
  end
end
