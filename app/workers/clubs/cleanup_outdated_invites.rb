class Clubs::CleanupOutdatedInvites
  include Sidekiq::Worker

  OUTDATE_INTERVAL = 4.months

  def perform
    ClubInvite
      .where('created_at < ?', OUTDATE_INTERVAL.ago)
      .find_each(&:destroy!)
  end
end
