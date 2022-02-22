class Review::ConvertToComment
  method_object :review

  def call
    comment = build_comment
    comment.instance_variable_set :@is_migration, true

    ApplicationRecord.transaction do
      Comment.wo_antispam { comment.save! }

      Comments::Move.call(
        comment_ids: replies_ids,
        commentable: @review.maybe_topic(@review.locale),
        from_reply: @review.maybe_topic(@review.locale),
        to_reply: comment
      )

      move_review_relations comment
      @review.destroy!
    end

    comment
  end

private

  def build_comment
    Comment.new(
      user: @review.user,
      body: @review.body,
      commentable: @review.db_entry.topic(@review.locale),
      created_at: @review.created_at,
      updated_at: @review.updated_at
    )
  end

  def move_review_relations comment
    @review.bans.update_all comment_id: comment.id, review_id: nil
    @review.abuse_requests.update_all comment_id: comment.id, review_id: nil
  end

  def replies_ids
    Comments::RepliesByBbCode
      .call(
        model: @review,
        commentable: @review
      )
      .map(&:id)
  end
end
