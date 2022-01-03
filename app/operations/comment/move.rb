class Comment::Move
  method_object %i[comment commentable]

  def call
    @comment.update(
      commentable_id: @commentable.id,
      commentable_type: @commentable.class.base_class.name
    )
  end
end
