class Comment::Cleanup
  method_object :comment, %i[is_cleanup_summaries is_cleanup_quotes]

  IMAGES_REGEXP = /\[(?<type>image|poster)=(?<user_image_id>\d+)/mix
  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER

  def call
    return if @comment.is_summary && !@is_cleanup_summaries

    new_body = cleanup @comment.body, extract_quoted_images(@comment.body)

    @comment.update_column :body, new_body if new_body != @comment.body
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
        match.scan(IMAGES_REGEXP).map(&:second)
      end
  end

  def image_ids_in_code body
    code_tag = BbCodes::Tags::CodeTag.new
    code_tag.preprocess(body)
    code_tag.cache.flat_map { |cache| cache[:text].scan(IMAGES_REGEXP).map(&:second) }
  end

  def cleanup body, skip_ids
    body.gsub(IMAGES_REGEXP) do |match|
      image_id = $LAST_MATCH_INFO[:user_image_id]
      next match if skip_ids.include? image_id

      UserImage.find_by(id: image_id)&.destroy
      "[#{$LAST_MATCH_INFO[:type]}=#{DELETED_MARKER}"
    end
  end
end
