class Messages::MarkRepliesAsRead
  method_object %i[
    body!
    user_id!
  ]

  def call
    matched_ids = []
    @body.scan(BbCodes::Tags::MessageTag.instance.bbcode_regexp) do
      matched_ids.push $LAST_MATCH_INFO[:id].to_i
    end

    if matched_ids.any?
      Message.where(id: matched_ids, to_id: @user_id).update_all read: true
    end
  end
end
