class Comments::RepliesByBbCode
  method_object :comment

  def call
    fetch @comment, [@comment.id.to_s]
  end

private

  def fetch comment, processed_ids
    comment.body
      .scan(BbCodes::Tags::RepliesTag::REGEXP)
      .map do |_, _, ids|
        ids.split(',').map { |id| process id, processed_ids }
      end
      .flatten
  end

  def process comment_id, processed_ids
    return [] if processed_ids.include? comment_id

    processed_ids.push comment_id
    comment = Comment.find_by(
      id: comment_id,
      commentable_id: @comment.commentable_id,
      commentable_type: @comment.commentable_type
    )
    return [] unless comment

    [comment] + fetch(comment, processed_ids)
  end
end
