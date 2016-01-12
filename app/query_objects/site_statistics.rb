class SiteStatistics
  METRIKA_MONTHS = 18
  CLASS_MONTHS = 6

  USERS_LIMIT = 31

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
    Comment.last.try(:id)
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
    User.where(id: [1897, 35934])
  end

  def thanks_to
    User.where(id: [2,11,19,861,950,1945,864,6452,28133,23002]).order(:id)
  end

  def versions_moderators
    User.where(id: User::VERSIONS_MODERATORS - User::ADMINS)
  end

  def retired_moderators
    User.where(id: [942, 2033]).order(:id) # 942 - Иштаран, 2033 - zmej1987
  end

  def forum_moderators
    User.where(id: User::MODERATORS - User::ADMINS)
  end

  def cosplay_moderators
    User.where(id: User::COSPLAY_MODERATORS - User::ADMINS)
  end

  def translators
    User
      .joins(:versions)
      .where.not(id: [1, User::GUEST_ID] + BotsService.posters)
      .where(versions: { state: [:accepted, :taken] })
      .group('users.id')
      .having("sum(case when versions.state='#{:accepted}' and (item_diff->>#{User.sanitize :description}) is not null then 7 else 1 end) > 10")
      .order("sum(case when versions.state='#{:accepted}' and (item_diff->>#{User.sanitize :description}) is not null then 7 else 1 end) desc")
      .limit(USERS_LIMIT * 4)
  end

  def reviewers
    User
      .joins(:reviews)
      .group('users.id')
      .order('count(reviews.id) desc')
      .limit(USERS_LIMIT)
  end

  def newsmakers
    newsmakers = Topics::NewsTopic.where(generated: false).group(:user_id).count
    newsmarker_ids = newsmakers
        .sort_by {|k,v| -v }
        .map(&:first)
        .take(USERS_LIMIT)

    User.where(id: newsmarker_ids).sort_by {|v| newsmarker_ids.index(v.id) }
  end

  def top_video_contributors
    AnimeOnline::Contributors.top(USERS_LIMIT * 2)
  end

private

  def by_class klass, interval
    start_date = Time.zone.today - interval

    entries_by_date = klass
      .where('created_at > ?', start_date)
      .where('created_at < ?', Time.zone.today)
      .group('cast(created_at as date)')
      .order('cast(created_at as date)')
      .select('cast(created_at as date) as date, count(*) as count')
      .each_with_object({}) {|v,memo| memo[v.date.to_s] = v.count }

    date = start_date
    statistics = {}
    while date < Time.zone.today
      statistics[date.to_s] = entries_by_date[date.to_s] || 0
      date += 1.day
    end
    statistics.map do |k, v|
      {
        date: k,
        count: v
      }
    end
  end
end
