class Comment::Cleanup
  method_object :comment, %i[is_cleanup_summaries is_cleanup_quotes skip_model_update]

  IMAGES_SCAN_REGEXP = /\[(?:image|poster)=(\d+)/mix
  IMAGES_REPLACEMENT_REGEXP = /\[(?<type>image|poster)=(?<user_image_id>\d+)/mix
  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER

  delegate :scan_user_image_ids, to: :class

  def call
    new_body = cleanup(
      text: @comment.body,
      skip_ids: extract_quoted_images,
      user_owned_image_ids: extract_user_owned_image_ids
    )

    if !@skip_model_update && new_body != @comment.body
      @comment.update_column :body, new_body
    end
  end

  def self.scan_user_image_ids text
    text.scan(IMAGES_SCAN_REGEXP).map { |v| v[0].to_i }.uniq
  end

private

  def extract_quoted_images
    return [] if @is_cleanup_quotes

    image_ids_in_quotes(@comment.body) + image_ids_in_code(@comment.body)
  end

  def extract_user_owned_image_ids
    UserImage
      .where(id: scan_user_image_ids(@comment.body), user_id: @comment.user_id)
      .pluck(:id)
  end

  def image_ids_in_quotes body
    body
      .gsub(BbCodes::Markdown::ListQuoteParser::MARKDOWN_LIST_OR_QUOTE_REGEXP)
      .flat_map { |match| scan_user_image_ids match }
  end

  def image_ids_in_code body
    code_tag = BbCodes::Tags::CodeTag.new
    code_tag.preprocess(body)
    code_tag.cache.flat_map { |cache| scan_user_image_ids cache[:text] }
  end

  def cleanup text:, skip_ids:, user_owned_image_ids:
    text.gsub(IMAGES_REPLACEMENT_REGEXP) do |match|
      id = $LAST_MATCH_INFO[:user_image_id].to_i
      next match if skip_ids.include?(id) || user_owned_image_ids.exclude?(id)

      UserImages::CleanupJob.perform_in 1.minute, id
      "[#{$LAST_MATCH_INFO[:type]}=#{DELETED_MARKER}"
    end
  end
end
