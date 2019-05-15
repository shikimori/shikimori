class CommentDecorator < BaseDecorator
  instance_cache :html_body

  def html_body
    if persisted?
      Rails.cache.fetch CacheHelper.keys(:body, object, :v4) do
        object.html_body
      end
    else
      object.html_body
    end
  end

  def broadcast?
    object.body.include? Comment::Broadcast::BB_CODE
  end
end
