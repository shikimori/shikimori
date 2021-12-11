# frozen_string_literal: true

class Comment::Update
  method_object %i[comment! params! faye!]

  def call
    is_updated = update_comment
    changelog if is_updated
    is_updated
  end

private

  def update_comment
    @faye.update @comment, @params
  end

  def changelog
    NamedLogger.changelog.info(
      user_id: @faye.actor&.id,
      action: :update,
      comment: { 'id' => @comment.id },
      changes: @comment.saved_changes.except('updated_at')
    )
  end
end
