class CommentDecorator < BaseDecorator
  instance_cache :html_body

  CACHE_VERSION = :v14

  def html_body
    return object.html_body if new_record?

    text = body
    cache_key = CacheHelperInstance.cache_keys(
      object.cache_key,
      XXhash.xxh32(text),
      CACHE_VERSION
    )

    Rails.cache.fetch(cache_key) { object.html_body }
  end

  def broadcast?
    body.include? Comment::Broadcast::BB_CODE
  end

  def offtopable?
    commentable_type != Review.name && not_from_club?
  end

  def not_from_club?
    commentable.linked_type != Club.name &&
    commentable.linked_type != ClubPage.name
  end
end
