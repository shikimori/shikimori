class Tags::CleanupImageboardsCacheJob
  include Sidekiq::Worker

  IMAGEBOARDS = %w[
    danbooru
    yandere
    konachan
    safebooru
  ]

  ONGOING_EXPIRES_IN = 2.weeks
  PAGES = (1..10).to_a

  def perform
    tags = extract_ongoing_tags

    IMAGEBOARDS.each do |imageboard|
      PAGES.each do |page|
        PgCacheData
          .where(key: pg_cache_keys(tags, imageboard, page))
          .where('expires_at < ?', (ImageboardsController::EXPIRES_IN - ONGOING_EXPIRES_IN).from_now)
          .delete_all
      end
    end
  end

private

  def pg_cache_keys tags, imageboard, page
    tags.map do |tag|
      ImageboardsController.pg_cache_key(
        tag: tag,
        imageboard: imageboard,
        page: page
      )
    end
  end

  def extract_ongoing_tags
    Anime
      .where(status: :ongoing)
      .includes(:characters)
      .flat_map do |anime|
        [anime.imageboard_tag] + anime.characters.map(&:imageboard_tag)
      end
      .select(&:present?)
  end
end
