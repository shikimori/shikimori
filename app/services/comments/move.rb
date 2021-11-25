class Comments::Move
  method_object %i[comment_ids! commentable!]

  def call
    return if comment_ids.none?

    Comment
      .where(id: @comment_ids)
      .update_all(
        commentable_id: @commentable.id,
        commentable_type: @commentable.class.base_class.name
      )
  end
end
