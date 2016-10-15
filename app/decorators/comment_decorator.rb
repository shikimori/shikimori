# не заменять на "class CommentDecorator < BaseDecorator" - ломает
class CommentDecorator < Draper::Decorator
  prepend ActiveCacher.instance
  delegate_all

  instance_cache :html_body

  def html_body
    if persisted?
      Rails.cache.fetch [:body, object] do
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
