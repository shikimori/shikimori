# добавление убирание ответа на комментарий
class ReplyService
  pattr_initialize :comment

  def append_reply replied_comment
    current_tag, ids = curernt_replies

    new_body = if current_tag.present?
      new_ids = (ids + [replied_comment.id]).sort.uniq
      comment.body.sub current_tag, "[replies=#{new_ids.join ','}]"
    else
      comment.body + "\n\n[replies=#{replied_comment.id}]"
    end

    update_comment new_body
  end

  def remove_reply replied_comment
    current_tag, ids = curernt_replies
    return unless current_tag || ids

    new_ids = ids - [replied_comment.id]

    new_body = if new_ids.any?
      comment.body.sub current_tag, "[replies=#{new_ids.join ','}]"
    else
      (comment.body.sub current_tag, "").strip
    end

    update_comment new_body
  end

private

  def update_comment new_body
    comment.update body: new_body
    faye.set_replies comment
  end

  def curernt_replies
    [$~[:tag], $~[:ids].split(',').map(&:to_i)] if comment.body =~ BbCodes::RepliesTag::REGEXP
  end

  def faye
    @faye ||= FayeService.new nil, nil
  end
end
