class SiteStatistics
  METRIKA_MONTHS = 18
  CLASS_MONTHS = 6

  USERS_LIMIT = 31

  TRANSALTION_SCORE_SQL = <<-SQL.squish
    sum(
      case
        when versions.state='accepted' and
          (item_diff->>#{ApplicationRecord.sanitize :description}) is not null
        then 7
        else 1
      end
    )
  SQL

  ACHIEVEMENT_USER_IDS = [3824, 210, 16398, 34807, 29386, 84020, 72620, 50587, 100600, 77362, 7642, 9158] # rubocop:disable all

  CACHE_VERSION = :v3

  def traffic
    YandexMetrika.call METRIKA_MONTHS
  end

  def comments
    by_class Comment, CLASS_MONTHS.month
  end

  def users
    by_class(
      User.where('read_only_at is null or read_only_at < ?', 10.years.from_now),
      CLASS_MONTHS.month
    )
  end

  def comments_count
    Comment.last.try(:id)
  end

  def users_count
    User.last.id
  end

  def contest_moderators
    User
      .where("roles && '{#{Types::User::Roles[:contest_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def developers
    User.where(id: User::MORR_ID)
  end

  def achievements
    User.where(id: ACHIEVEMENT_USER_IDS).sort_by { |v| ACHIEVEMENT_USER_IDS.index v.id }
  end

  def thanks_to
    User
      .where(id: [2, 11, 19, 861, 950, 1945, 864, 6452, 28_133, 23_002, 30_214, 124_689, 76_437])
      .order(:id)
  end

  def version_moderators
    User
      .where("roles && '{#{Types::User::Roles[:version_names_moderator]}}'")
      .or(User.where("roles && '{#{Types::User::Roles[:version_texts_moderator]}}'"))
      .or(User.where("roles && '{#{Types::User::Roles[:version_moderator]}}'"))
      .or(User.where("roles && '{#{Types::User::Roles[:version_fansub_moderator]}}'"))
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def retired_moderators
    User
      .where("roles && '{#{Types::User::Roles[:retired_moderator]}}'")
      .order(:id)
  end

  def forum_moderators
    User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def cosplay_moderators
    User.where(id: User::COSPLAY_MODERATORS - User::ADMINS)
  end

  def vk_admins
    User.where(id: [4795, 210_569]) # Harizmath, vibrant
  end

  def discord_admins
    User.where(id: 8014) # Happy Man
  end

  def translators
    User
      .joins(:versions)
      .where.not("roles && '{#{Types::User::Roles[:bot]}}'")
      .where.not(id: [User::MORR_ID, User::GUEST_ID])
      .where(versions: { state: %i[accepted taken auto_accepted] })
      .where.not(versions: { item_type: AnimeVideo.name })
      .group('users.id')
      .having("#{TRANSALTION_SCORE_SQL} > 10")
      .order(Arel.sql("#{TRANSALTION_SCORE_SQL} desc"))
      .limit(USERS_LIMIT * 4)
  end

  def reviewers
    User
      .joins(:critiques)
      .where.not(reviews: { moderation_state: :rejected })
      .group('users.id')
      .order(Arel.sql('count(reviews.id) desc'))
      .limit(USERS_LIMIT)
  end

  def newsmakers
    newsmakers = Topics::NewsTopic
      .where(generated: false)
      .group(:user_id)
      .count

    newsmarker_ids = newsmakers
      .sort_by { |_k, v| -v }
      .map(&:first)
      .take(USERS_LIMIT)

    User.where(id: newsmarker_ids).sort_by { |v| newsmarker_ids.index(v.id) }
  end

  def top_video_contributors
    AnimeOnline::Contributors.call limit: USERS_LIMIT * 2
  end

  def cache_key
    [:about_block, CACHE_VERSION, Time.zone.today]
  end

private

  def by_class klass, interval
    start_date = Time.zone.today - interval

    entries_by_date = klass
      .where('created_at > ?', start_date)
      .where('created_at < ?', Time.zone.today)
      .group('cast(created_at as date)')
      .order(Arel.sql('cast(created_at as date)'))
      .select('cast(created_at as date) as date, count(*) as count')
      .each_with_object({}) { |v, memo| memo[v.date.to_s] = v.count }

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
