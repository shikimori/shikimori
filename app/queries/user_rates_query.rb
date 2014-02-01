class UserRatesQuery
  def initialize(entry, user)
    @entry = entry
    @user = user
  end

  # оценки друзей пользователя
  def friend_rates
    UserRate
      .where(target_id: @entry.id, target_type: @entry.class.name)
      .where(user_id: @user.friend_links.pluck(:dst_id))
      .includes(:user)
      .sort_by {|v| v.user.nickname }
  end

  # последние изменения от всех пользователей
  def recent_rates(limit)
    UserRate
      .where(target_id: @entry.id, target_type: @entry.class.name)
      .includes(:user)
      .order(updated_at: :desc)
      .limit(limit)
  end
end
