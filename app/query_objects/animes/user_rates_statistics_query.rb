class Animes::UserRatesStatisticsQuery
  pattr_initialize :entry, :user

  def friend_rates
    @entry.rates
      .where(user_id: @user.friend_links.pluck(:dst_id))
      .includes(:user)
      .sort_by(&:updated_at)
      .reverse
  end
end
