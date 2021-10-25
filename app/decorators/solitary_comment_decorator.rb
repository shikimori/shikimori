class SolitaryCommentDecorator < CommentDecorator
  def topic_name
    (
      "<span class='normal'>#{formatted.match(/^(.*?)</)[1]}" \
        "</span> #{h.sanitize formatted.match(/>(.*?)</)[1]}"
    ).html_safe
  end

  def topic_url
    formatted.match(/href="(.*?)"/)[1]
  end

private

  def formatted
    @formatted ||= Messages::MentionSource.call commentable, comment_id: id
  end
end
