class Tags::CleanupCoubCacheJob
  include Sidekiq::Worker

  ONGOING_EXPIRES_IN = 1.week
  PAGES = (1..10).to_a

  def perform
    tags = extract_ongoing_tags

    PAGES.each do |page|
      PgCacheData
        .where(key: pg_cache_keys(tags, page))
        .where('expires_at < ?', (CoubTags::CoubRequest::EXPIRES_IN - ONGOING_EXPIRES_IN).from_now)
        .delete_all
    end
  end

private

  def pg_cache_keys tags, page
    tags.map do |tag|
      CoubTags::CoubRequest.pg_cache_key(
        tag: tag,
        page: page
      )
    end
  end

  def extract_ongoing_tags
    Anime
      .where(status: :ongoing)
      .flat_map(&:coub_tags)
  end
end
