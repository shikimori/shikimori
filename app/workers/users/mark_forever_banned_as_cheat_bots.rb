class Users::MarkForeverBannedAsCheatBots
  include Sidekiq::Worker

  FOREVER_BAN_INTERVAL = 2.years
  ACTIVE_INTERVAL = 6.months

  def perform
    User
      .where('read_only_at > ?', FOREVER_BAN_INTERVAL.from_now)
      .where('last_online_at < ?', ACTIVE_INTERVAL.ago)
      .where.not("roles && '{#{Types::User::Roles[:cheat_bot]}}'")
      .find_each do |user|
        user.update! roles: user.roles.values + [Types::User::Roles[:cheat_bot].to_s]
      end
  end
end
