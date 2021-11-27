class Review::ConvertToComment
  method_object :review

  def call
    comment = build_comment

    Comment.wo_antispam { comment.save! }

    Comments::Move.call comment_ids: replies_ids, commentable: commentable
    @review.destroy!

    comment
  end

private

  def build_comment
    Comment.new(
      user: @review.user,
      body: @review.body,
      commentable: commentable,
      created_at: @review.created_at,
      updated_at: @review.updated_at
    )
  end

  def replies_ids
    Comments::RepliesByBbCode
      .call(
        model: @review,
        commentable: @review
      )
      .map(&:id)
  end

  def commentable
    @review.db_entry.topic @review.locale
  end
end
