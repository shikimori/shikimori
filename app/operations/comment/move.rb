class Comment::Move
  method_object %i[comment! to! basis]

  def call
    change_replies
    change_commentable

    @comment.save
  end

private

  def change_replies
  end

  def change_commentable
    @comment.assign_attributes(
      commentable_id: @to.id,
      commentable_type: @to.class.base_class.name
    )
  end
end
