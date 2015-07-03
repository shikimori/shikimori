class FinishExpiredAnimes
  include Sidekiq::Worker

  EXPIRE_INTERVAL = 2.days

  def perform
    expired_anonses.each {|v| v.update status: :ongoing }
    expired_ongoings.each {|v| v.update status: :released }
  end

private

  def expired_anonses
    Anime
      .where(status: :anons)
      .where('aired_on is not null and aired_on < ?', EXPIRE_INTERVAL.ago)
  end

  def expired_ongoings
    Anime
      .where(status: :ongoing)
      .where('released_on is not null and released_on < ?', EXPIRE_INTERVAL.ago)
  end
end
