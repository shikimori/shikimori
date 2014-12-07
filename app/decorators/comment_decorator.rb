# не заменять на "class CommentDecorator < BaseDecorator" - ломает
class CommentDecorator < Draper::Decorator
  delegate_all

  def can_be_edited?
    can_be_edited_by? h.current_user
  end

  def html_body
    if comment.persisted?
      Rails.cache.fetch([comment, :body]) { comment.html_body }
    else
      comment.html_body
    end
  end
end
