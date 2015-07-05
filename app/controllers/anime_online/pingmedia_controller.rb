class AnimeOnline::PingmediaController < ShikimoriController
  layout false

  before_action { noindex && nofollow }

  def iframe_240x400
  end

  def iframe_728x90
  end

  def iframe_240x400_advertur
  end

  def iframe_728x90_advertur
  end
end
