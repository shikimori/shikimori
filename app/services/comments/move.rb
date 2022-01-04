class Comments::Move
  method_object %i[comment_ids! to! basis]

  def call
    return if comment_ids.none?

    Comment
      .where(id: @comment_ids)
      .find_each do |comment|
        Comment::Move.call(
          comment: comment,
          to: @to,
          basis: @basis
        )
      end
  end
end
