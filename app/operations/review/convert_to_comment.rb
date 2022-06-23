class Review::ConvertToComment
  method_object :review

  def call
    comment = build_comment
    comment.instance_variable_set :@is_conversion, true

    ApplicationRecord.transaction do
      Comment.wo_antispam { comment.save! }

      Comments::Move.call(
        comment_ids: replies_ids,
        commentable: db_entry_topic,
        from_reply: review_topic,
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
    review_topic.bans.update_all comment_id: comment.id, topic_id: nil
    review_topic.abuse_requests.update_all comment_id: comment.id, topic_id: nil
  end

  def review_topic
    @review.maybe_topic @review.locale
  end

  def db_entry_topic
    @review.db_entry.topic @review.locale
  end

  def replies_ids
    Comments::RepliesByBbCode
      .call(
        model: @review,
        commentable: @review.maybe_topic(@review.locale)
      )
      .map(&:id)
  end
end
