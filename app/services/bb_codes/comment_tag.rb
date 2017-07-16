class BbCodes::CommentTag
  include Singleton

  REGEXP = %r{
    \[comment=(?<comment_id>\d+)\]
      (?<text> .*? )
    \[/comment\]
  }mix

  def format text
    text.gsub(REGEXP) do
      comment = Comment.find_by id: $LAST_MATCH_INFO[:comment_id]
      if comment
        comment_to_html comment, $LAST_MATCH_INFO[:text]
      else
        $LAST_MATCH_INFO[:text]
      end
    end
  end

private

  def comment_to_html comment, text
    BbCodes::UrlTag.instance.format(
      "[url=#{UrlGenerator.instance.comment_url comment}]#{text}[/url]"
    )
  end
end
