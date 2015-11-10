# не заменять на "class CommentDecorator < BaseDecorator" - ломает
class CommentDecorator < Draper::Decorator
  prepend ActiveCacher.instance
  delegate_all

  instance_cache :html_body, :replies, :reply_comments_view

  def can_be_edited?
    can_be_edited_by? h.current_user
  end

  def html_body
    if persisted?
      Rails.cache.fetch [:body, h.russian_names_key, object] do
        object.html_body
      end
    else
      object.html_body
    end
  end
end
