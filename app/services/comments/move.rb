class Comments::Move
  method_object %i[comment_ids! commentable! from_basis to_basis]

  def call
    return if comment_ids.none?

    Comment
      .where(id: @comment_ids)
      .find_each do |comment|
        Comment::Move.call(
          comment: comment,
          commentable: @commentable,
          from_basis: @from_basis,
          to_basis: @to_basis
        )
      end
  end
end
