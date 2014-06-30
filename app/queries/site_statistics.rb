class SiteStatistics
  METRIKA_MONTHS = 18
  CLASS_MONTHS = 6

  def traffic
    YandexMetrika.new.traffic_for_months METRIKA_MONTHS
  end

  def comments
    by_class Comment, CLASS_MONTHS.month
  end

  def users
    by_class User, CLASS_MONTHS.month
  end

  def comments_count
    Comment.last.id
  end

  def users_count
    User.last.id
  end

  def contest_moderators
    User.where(id: 1483)
  end

  def developers
    User.where(id: 1)
  end

  def android
    User.where(id: 1897)
  end

  def thanks_to
    User.where(id: [2,11,19,861,950,1945,864,6452]).order(:id)
  end

  def user_changes_moderators
    User.where(id: User::UserChangesModerators - User::Admins)
  end

  def forum_moderators
    User.where(id: User::Moderators - User::Admins)
  end

  def cosplay_moderators
    User.where(id: User::CosplayModerators - User::Admins)
  end

  def translators
    User
      .joins(:user_changes)
      .where.not(id: [1, User::GuestID] + BotsService.posters)
      .where(user_changes: { status: [UserChangeStatus::Accepted, UserChangeStatus::Taken] })
      .group('users.id')
      .having("sum(case when user_changes.status='#{UserChangeStatus::Accepted}' then 7 else 1 end) > 10")
      .order("sum(case when user_changes.status='#{UserChangeStatus::Accepted}' then 7 else 1 end) desc")
      .limit(96)
      #.select("users.*, sum(if(user_changes.status='#{UserChangeStatus::Accepted}',7,1)) as points")
      #.each {|v| v.nickname = v.points.to_i.to_s }
  end

  def reviewers
    User
      .joins(:reviews)
      .group('users.id')
      .order('count(reviews.id) desc')
      .limit(24)
  end

  def newsmakers
    anime_newsmakers = AnimeNews.where(generated: false).group(:user_id).count
    manga_newsmakers = MangaNews.where(generated: false).group(:user_id).count
    manga_newsmakers.each do |user_id, count|
      anime_newsmakers[user_id] ||= 0
      anime_newsmakers[user_id] += count
    end
    newsmarker_ids = anime_newsmakers
        .sort_by {|k,v| -v }
        .map(&:first)
        .take(24)

    User.where(id: newsmarker_ids).sort_by {|v| newsmarker_ids.index(v.id) }
  end

private
  def by_class klass, interval
    start_date = Date.today - interval

    entries_by_date = klass
      .where('created_at > ?', start_date)
      .where('created_at < ?', Date.today)
      .group('cast(created_at as date), created_at')
      .order(:created_at)
      .count
      .each_with_object({}) {|(k,v),memo| memo[k.to_s] = v }

    date = start_date
    statistics = {}
    while date < Date.today
      statistics[date.to_s] = entries_by_date[date.to_s] || 0
      date += 1.day
    end
    statistics.map {|k,v| {date: k, count: v} }
  end
end
