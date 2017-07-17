class BbCodes::QuoteTag
  include Singleton

  def format text
    return text unless text.include?('[quote') && text.include?('[/quote]')

    simple_quote(topic_quote(message_quote(comment_quote(quote_end(text)))))
  end

private

  def simple_quote text
    text
      .gsub(/\[quote\]\n?/, '<div class="b-quote">')
      .gsub(
        /\[quote=([^\]]+)\]\n?/,
        '<div class="b-quote"><div class="quoteable">[user]\1[/user]</div>'
      )
  end

  def topic_quote text
    text.gsub(
      /\[quote=t(\d+);(\d+);([^\]]+)\]\n?/,
      '<div class="b-quote">'\
        '<div class="quoteable">[topic=\1 quote]\3[/topic]'\
        '</div>'
    )
  end

  def message_quote text
    text.gsub(
      /\[quote=m(\d+);(\d+);([^\]]+)\]\n?/,
      '<div class="b-quote">'\
        '<div class="quoteable">[message=\1 quote]\3[/message]'\
        '</div>'
    )
  end

  def comment_quote text
    text.gsub(
      /\[quote=c?(\d+);(\d+);([^\]]+)\]\n?/,
      '<div class="b-quote">'\
        '<div class="quoteable">[comment=\1 quote]\3[/comment]'\
        '</div>'
    )
  end

  def quote_end text
    text.gsub(%r{\[/quote\]\n?}, '</div>')
  end
end
