class Comments::Reply
  pattr_initialize :comment

  def reply_ids
    extract_replies[1]
  end

  def append_reply replied_comment
    current_tag, ids, brs = extract_replies

    new_body =
      if current_tag.present?
        new_ids = (ids + [replied_comment.id]).sort.uniq
        comment.body.sub current_tag, "#{brs}[replies=#{new_ids.join ','}]"
      else
        comment.body + "\n\n[replies=#{replied_comment.id}]"
      end

    update_comment new_body
  end

  def remove_reply replied_comment
    current_tag, ids, brs = extract_replies
    return unless current_tag || ids.any?

    new_ids = ids - [replied_comment.id]

    new_body =
      if new_ids.any?
        comment.body.sub current_tag, "#{brs}[replies=#{new_ids.join ','}]"
      else
        (comment.body.sub current_tag, '').strip
      end

    update_comment new_body
  end

private

  def update_comment new_body
    # use update instead of update_column so `commentable` is touched too
    comment.instance_variable_set :@skip_banhammer, true
    comment.update(
      body: new_body,
      updated_at: comment.updated_at + 1.second
    )
    faye.set_replies comment
  end

  def extract_replies
    if comment.body =~ BbCodes::Tags::RepliesTag::REGEXP
      [
        $LAST_MATCH_INFO[:tag],
        $LAST_MATCH_INFO[:ids].split(',').map(&:to_i),
        $LAST_MATCH_INFO[:brs]
      ]
    else
      [nil, [], nil]
    end
  end

  def faye
    @faye ||= FayeService.new nil, nil
  end
end
