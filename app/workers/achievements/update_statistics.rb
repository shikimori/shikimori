class Achievements::UpdateStatistics
  include Sidekiq::Worker

  sidekiq_options queue: :achievements

  USER_RATES_SQL = <<~SQL.squish
    inner join user_rates on
      users.id = user_rates.user_id and
      user_rates.status in (
        #{UserRate.statuses[:completed]},
        #{UserRate.statuses[:rewatching]}
      )
  SQL

  def perform
    statistics = build_statistics
    write_cache statistics

    statistics
  end

private

  def build_statistics # rubocop:disable MethodLength
    total = Neko::Stats.new
    statistics = {
      Achievements::Statistics::TOTAL_KEY => {
        Achievements::Statistics::TOTAL_LEVEL => total
      }
    }

    users_scope.find_each do |user|
      total.increment! user.user_rates_count
      # puts user.id

      user.achievements.each do |achievement|
        # ap achievement
        process_achievement(
          user.user_rates_count,
          achievement.neko_id.to_sym,
          achievement.level.to_s.to_sym,
          statistics
        )
      end
    end

    statistics
  end

  def write_cache statistics
    PgCache.write(
      Achievements::Statistics::CACHE_KEY,
      statistics
    )
  end

  def process_achievement user_rates_count, neko_id, level, statistics
    statistics[neko_id] ||= {}
    statistics[neko_id][level] ||= Neko::Stats.new
    statistics[neko_id][level].increment! user_rates_count
  end

  def users_scope
    User
      .includes(:achievements)
      .where.not("roles && '{#{Types::User::Roles[:cheat_bot]}}'")
      .where.not("roles && '{#{Types::User::Roles[:completed_announced_animes]}}'")
      .where.not("roles && '{#{Types::User::Roles[:ignored_in_achievement_statistics]}}'")
      .joins(USER_RATES_SQL)
      .group('users.id')
      .select('users.id, count(*) as user_rates_count')
      # .where('users.id >= 68601 and users.id <= 69601')
  end
end
