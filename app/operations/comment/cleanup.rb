class Comment::Cleanup
  method_object :comment, %i[is_cleanup_summaries is_cleanup_quotes skip_model_update]

  IMAGES_SCAN_REGEXP = /\[(?:image|poster)=(\d+)/mix
  IMAGES_REPLACEMENT_REGEXP = /\[(?<type>image|poster)=(?<user_image_id>\d+)/mix
  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER

  def call
    return if @comment.is_summary && !@is_cleanup_summaries

    new_body = cleanup @comment.body, extract_quoted_images(@comment.body)

    if !@skip_model_update && new_body != @comment.body
      @comment.update_column :body, new_body
    end
  end

  def self.scan_user_image_ids text
    text.scan(IMAGES_SCAN_REGEXP).map { |v| v[0].to_i }.uniq
  end

private

  def extract_quoted_images body
    return [] if @is_cleanup_quotes

    image_ids_in_quotes(body) + image_ids_in_code(body)
  end

  def image_ids_in_quotes body
    body
      .gsub(BbCodes::Markdown::ListQuoteParser::MARKDOWN_LIST_OR_QUOTE_REGEXP)
      .flat_map do |match|
        self.class.scan_user_image_ids match
      end
  end

  def image_ids_in_code body
    code_tag = BbCodes::Tags::CodeTag.new
    code_tag.preprocess(body)
    code_tag.cache.flat_map { |cache| self.class.scan_user_image_ids cache[:text] }
  end

  def cleanup body, skip_ids
    body.gsub(IMAGES_REPLACEMENT_REGEXP) do |match|
      user_image_id = $LAST_MATCH_INFO[:user_image_id].to_i
      next match if skip_ids.include? user_image_id

      UserImages::CleanupJob.perform_in 1.minute, user_image_id
      "[#{$LAST_MATCH_INFO[:type]}=#{DELETED_MARKER}"
    end
  end
end
