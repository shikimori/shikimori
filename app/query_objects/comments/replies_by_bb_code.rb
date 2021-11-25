class Comments::RepliesByBbCode
  method_object %i[model! commentable!]

  def call
    fetch @model.body, [@model.id.to_s]
  end

private

  def fetch text, processed_ids
    text
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
      commentable_id: @commentable.id,
      commentable_type: @commentable.class.base_class.name
    )
    return [] unless comment

    [comment] + fetch(comment.body, processed_ids)
  end
end
