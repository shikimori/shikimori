# не заменять на "class CommentDecorator < BaseDecorator" - ломает
class CommentDecorator < Draper::Decorator
  prepend ActiveCacher.instance
  delegate_all

  instance_cache :html_body, :replies, :reply_comments_view

  def can_be_edited?
    h.can? :edit, object
  end

  def html_body
    if persisted?
      Rails.cache.fetch [:body, object] do
        object.html_body
      end
    else
      object.html_body
    end
  end
end
