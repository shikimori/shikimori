class Topic::Cleanup
  method_object :topic

  COMMENTS_OFFSET = 1_000
  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER

  IMAGES_REGEXP = /\[(?<type>image|poster)=(?<user_image_id>\d+)/mix

  def call
    return if topic.comments_count < COMMENTS_OFFSET

    topic
      .comments
      .where('id < ?', offset_comment(@topic).id)
      .find_each { |comment| cleanup comment }
  end

private

  def offset_comment topic
    topic
      .comments
      .order(id: :desc)
      .offset(COMMENTS_OFFSET - 1)
      .limit(1)
      .to_a
      .first
  end

  def cleanup comment
    new_body = comment.body.gsub(IMAGES_REGEXP) do
      UserImage.find_by(id: $LAST_MATCH_INFO[:user_image_id])&.destroy
      "[#{$LAST_MATCH_INFO[:type]}=#{DELETED_MARKER}"
    end

    comment.update_column :body, new_body if new_body != comment.body
  end
end
