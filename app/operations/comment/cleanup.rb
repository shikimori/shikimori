class Comment::Cleanup
  method_object :comment, %i[is_cleanup_summaries]

  IMAGES_REGEXP = /\[(?<type>image|poster)=(?<user_image_id>\d+)/mix
  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER

  def call
    return if @comment.is_summary && !@is_cleanup_summaries

    new_body = @comment.body.gsub(IMAGES_REGEXP) do
      UserImage.find_by(id: $LAST_MATCH_INFO[:user_image_id])&.destroy
      "[#{$LAST_MATCH_INFO[:type]}=#{DELETED_MARKER}"
    end

    @comment.update_column :body, new_body if new_body != @comment.body
  end
end
