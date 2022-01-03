class Comments::Move
  method_object %i[comment_ids! commentable!]

  def call
    return if comment_ids.none?

    Comment
      .where(id: @comment_ids)
      .find_each do |comment|
        Comment::Move.call comment: comment, commentable: @commentable
      end
  end
end
