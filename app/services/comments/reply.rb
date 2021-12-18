class Comments::Reply
  pattr_initialize :model

  def reply_ids
    extract_replies[1]
  end

  def append_reply replied_model
    current_tag, ids, brs = extract_replies

    new_body =
      if current_tag.present?
        new_ids = (ids + [replied_model.id]).sort.uniq
        model.body.sub current_tag, "#{brs}[replies=#{new_ids.join ','}]"
      else
        model.body + "\n\n[replies=#{replied_model.id}]"
      end

    update_model new_body
  end

  def remove_reply replied_model
    current_tag, ids, brs = extract_replies
    return unless current_tag || ids.any?

    new_ids = ids - [replied_model.id]

    new_body =
      if new_ids.any?
        model.body.sub current_tag, "#{brs}[replies=#{new_ids.join ','}]"
      else
        (model.body.sub current_tag, '').strip
      end

    update_model new_body
  end

private

  def update_model new_body
    # use update instead of update_column so `commentable` is touched too
    model.instance_variable_set :@skip_banhammer, true
    model.update(
      body: new_body,
      updated_at: model.updated_at + 1.second
    )
    faye.set_replies model if model.is_a? Comment
  end

  def extract_replies
    if model.body =~ BbCodes::Tags::RepliesTag::REGEXP
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
