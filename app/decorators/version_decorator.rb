class VersionDecorator < BaseDecorator
  def changed_fields
    item_diff.keys
  end

  def processable?
    h.user_signed_in? && h.current_user.user_changes_moderator?
  end
end
