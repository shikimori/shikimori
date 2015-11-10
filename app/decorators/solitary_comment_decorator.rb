class SolitaryCommentDecorator < CommentDecorator
  def topic_name
    ("<span class='normal'>#{formatted.match(/^(.*?)</)[1]}" +
      "</span> #{h.sanitize formatted.match(/>(.*?)</)[1]}").html_safe
  end

  def topic_url
    formatted.match(/href="(.*?)"/)[1]
  end

private

  def formatted
    h.format_linked_name commentable_id, commentable_type, id
  end
end
