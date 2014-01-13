class CommentDecorator < Draper::Decorator
  delegate_all

  def can_be_edited?
    can_be_edited_by? h.current_user
  end
end
