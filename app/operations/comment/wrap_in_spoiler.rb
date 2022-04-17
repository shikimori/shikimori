class Comment::WrapInSpoiler
  method_object :comment

  SPOILER_START = "[spoiler=Скрыто модератором]\n"
  SPOILER_END = "\n[/spoiler]"

  REGEXP = /
    \A
    (?<text>[\s\S]*?)
    (?<stuff>
      #{Topics::DecomposedBody::SYSTEM_STUFF_REGEXP}
    )
    \Z
  /mix

  def call
    return if already_wrapped?

    @comment.update body: wrapped_body
  end

private

  def already_wrapped?
    @comment.body.starts_with? SPOILER_START
  end

  def wrapped_body
    match = @comment.body.match REGEXP

    "#{SPOILER_START}#{match[:text]}#{SPOILER_END}#{match[:stuff]}"
  end
end
