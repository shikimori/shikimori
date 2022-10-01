class Review::ConvertToComment
  method_object :review

  def call
    ApplicationRecord.transaction do
      comment = Comment.wo_antispam { create_comment }

      Comments::Move.call(
        comment_ids: replies_ids,
        commentable: db_entry_topic,
        from_reply: review_topic,
        to_reply: comment
      )

      move_review_relations comment
      @review.destroy!
      comment
    end
  end

private

  def create_comment
    Comment::Create.call(
      params: {
        user: @review.user,
        body: @review.body,
        commentable_id: @review.db_entry_id,
        commentable_type: @review.anime? ? Anime.name : Manga.name,
        created_at: @review.created_at,
        updated_at: @review.updated_at
      },
      faye: FayeService.new(@review.user, nil),
      is_forced: true,
      is_conversion: true
    )
  end

  def move_review_relations comment
    review_topic.bans.update_all comment_id: comment.id, topic_id: nil
    review_topic.abuse_requests.update_all comment_id: comment.id, topic_id: nil
  end

  def review_topic
    @review.maybe_topic
  end

  def db_entry_topic
    @review.db_entry.topic
  end

  def replies_ids
    Comments::RepliesByBbCode
      .call(
        model: @review,
        commentable: @review.maybe_topic
      )
      .map(&:id)
  end
end
