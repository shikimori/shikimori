class Screenshots::Cleanup
  include Sidekiq::Worker
  MAXIMUM_SCREENSHOTS = 75

  def perform
    animes.each do |anime|
      anime.screenshots[MAXIMUM_SCREENSHOTS..-1].each(&:destroy)
    end
  end

private

  def animes
    Anime
      .where(id: anime_with_screenshots)
      .includes(:screenshots)
      .select { |anime| anime.screenshots.size > MAXIMUM_SCREENSHOTS }
  end

  def anime_with_screenshots
    Screenshot.select('distinct(anime_id) as anime_id').map(&:anime_id)
  end
end
