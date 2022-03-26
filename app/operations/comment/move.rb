class Comment::Move
  method_object %i[comment! commentable! from_reply to_reply]

  def call
    change_replies if @from_reply && @to_reply
    change_commentable

    @comment.save
  end

private

  def change_replies
    @comment.body = BbCodes::Quotes::Replace.call(
      text: @comment.body,
      from_reply: @from_reply,
      to_reply: @to_reply
    )
  end

  def change_commentable
    @comment.assign_attributes(
      commentable_id: @commentable.id,
      commentable_type: @commentable.class.base_class.name
    )
    @comment.instance_variable_set :@skip_notify_quoted, true
  end
end
