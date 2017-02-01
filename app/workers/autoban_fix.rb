class AutobanFix
  include Sidekiq::Worker

  def perform
    User
      .where('read_only_at > ?', 1.year.from_now)
      .includes(:bans, :history)
      .select { |user| user.bans.none? { |ban| ban.duration.to_i > 504000 } }
      .select { |user| user.history.size > 1 }
      .each { |user| user.update read_only_at: nil }
  end
end
