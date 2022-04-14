class Comment::WrapInSpoiler
  method_object :comment

  def call
    decomposed_body = @comment.body.match Topics::DecomposedBody::PARSE_REGEXP
    body_witout_stuff = decomposed_body[:text]
    stuff = (decomposed_body[:replies] || '') + (decomposed_body[:bans] || '')
    unless body_witout_stuff.starts_with?("[spoiler=Скрыто модератором]") &&
            body_witout_stuff.ends_with?("[/spoiler]")
      @comment.update(body: "[spoiler=Скрыто модератором]#{body_witout_stuff}[/spoiler]#{stuff}")
    end
  end
end
