class Comments::Move
  method_object %i[comment_ids! commentable! from_reply to_reply]

  def call
    return if comment_ids.none?

    Comment
      .where(id: @comment_ids)
      .find_each do |comment|
        Comment::Move.call(
          comment: comment,
          commentable: @commentable,
          from_reply: @from_reply,
          to_reply: @to_reply
        )
      end
  end
end
