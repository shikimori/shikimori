class CommentDecorator < BaseDecorator
  instance_cache :html_body

  CACHE_VERSION = :v14

  def html_body
    if persisted?
      text = object.body
      cache_key = CacheHelper.keys(
        object.cache_key,
        XXhash.xxh32(text),
        CACHE_VERSION
      )

      Rails.cache.fetch(cache_key) { object.html_body }
    else
      object.html_body
    end
  end

  def broadcast?
    object.body.include? Comment::Broadcast::BB_CODE
  end
end
