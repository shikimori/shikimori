class Achievements::UpdateStatistics
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executing,
    queue: :cpu_intensive
  )

  CACHE_KEY = Achievements::Statistics::CACHE_KEY

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
    statistics = {}

    users_scope.find_each do |user|
      user.achievements.each do |achievement|
        process_achievement(
          user,
          achievement.neko_id.to_sym,
          achievement.level.to_s.to_sym,
          statistics
        )
      end
    end

    statistics
  end

  def write_cache statistics
    Rails.application.redis.set CACHE_KEY, statistics.to_json
  end

  def process_achievement user, neko_id, level, statistics
    statistics[neko_id] ||= {}
    statistics[neko_id][level] ||= Neko::Statistics.new
    statistics[neko_id][level].increment! user.user_rates_count
  end

  def users_scope
    User
      .includes(:achievements)
      .joins(USER_RATES_SQL)
      .group('users.id')
      .select('users.id, count(*) as user_rates_count')
  end
end
