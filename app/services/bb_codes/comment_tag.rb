class BbCodes::CommentTag
  include Singleton

  REGEXP = %r{
    \[comment=(?<comment_id>\d+)\]
      (?<author_name> .*? )
    \[/comment\]
  }mix

  def format text
    text.gsub(REGEXP) do
      comment_to_html(
        $LAST_MATCH_INFO[:comment_id],
        $LAST_MATCH_INFO[:author_name]
      )
    end
  end

private

  def comment_to_html comment_id, author_name
    "[url=#{comment_url(comment_id)} bubbled]"\
      "@#{extract_author(comment_id, author_name)}[/url]"
  end

  def comment_url comment_id
    UrlGenerator.instance.comment_url comment_id
  end

  def extract_author comment_id, author_name
    return author_name if author_name.present?
    Comment.find_by(id: comment_id)&.user&.nickname || comment_id
  end
end
