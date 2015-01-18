class AnimeOnline::PingmediaController < ShikimoriController
  layout false

  before_action { noindex && nofollow }

  def google
  end

  def google_leaderboard
  end
end
