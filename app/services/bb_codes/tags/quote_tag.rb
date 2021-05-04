# rubocop:disable ClassLength
class BbCodes::Tags::QuoteTag
  include Singleton

  COMMENT_QUOTE_START_REGEXP = /
    \[quote=
      (?<attrs>
        c?(?<comment_id>\d+);
        (?<user_id>\d+);
        (?<nickname>[^\]]+)
      )
    \] \n?
  /mix

  MESSAGE_QUOTE_START_REGEXP = /
    \[quote=
      (?<attrs>
        m(?<message_id>\d+);
        (?<user_id>\d+);
        (?<nickname>[^\]]+)
      )
    \] \n?
  /mix

  TOPIC_QUOTE_START_REGEXP = /
    \[quote=
      (?<attrs>
        t(?<topic_id>\d+);
        (?<user_id>\d+);
        (?<nickname>[^\]]+)
      )
    \] \n?
  /mix

  SIMPLE_QUOTE_1_START_REGEXP = /
    \[quote\] \n?
  /mix

  SIMPLE_QUOTE_2_START_REGEXP = /
    \[quote=(?<attrs>(?<nickname>[^\]]+))\] \n?
  /mix

  QUOTE_END_REGEXP = %r{
    \n? \[/quote\] \n?
  }mix

  def format text
    return text unless text.include?('[/quote]')

    quote_end(*
      simple_quote_1(*
      simple_quote_2(*
      topic_quote(*
      message_quote(*
      comment_quote(*
        text,
        0,
        text))))))
  end

private

  def comment_quote text, replacements, original_text
    result = text.gsub COMMENT_QUOTE_START_REGEXP do
      replacements += 1
      attrs = $LAST_MATCH_INFO[:attrs]

      "<div class='b-quote' data-attrs='#{ERB::Util.h attrs}'><div class='quoteable'>" +
        BbCodes::Quotes::QuoteableToBbcode.instance.call(
          comment_id: $LAST_MATCH_INFO[:comment_id],
          user_id: $LAST_MATCH_INFO[:user_id],
          nickname: $LAST_MATCH_INFO[:nickname]
        ) +
        "</div><div class='quote-content'>"
    end

    [result, replacements, original_text]
  end

  def message_quote text, replacements, original_text
    result = text.gsub MESSAGE_QUOTE_START_REGEXP do
      replacements += 1
      attrs = $LAST_MATCH_INFO[:attrs]

      "<div class='b-quote' data-attrs='#{ERB::Util.h attrs}'><div class='quoteable'>" +
        BbCodes::Quotes::QuoteableToBbcode.instance.call(
          message_id: $LAST_MATCH_INFO[:message_id],
          user_id: $LAST_MATCH_INFO[:user_id],
          nickname: $LAST_MATCH_INFO[:nickname]
        ) +
        "</div><div class='quote-content'>"
    end

    [result, replacements, original_text]
  end

  def topic_quote text, replacements, original_text
    result = text.gsub TOPIC_QUOTE_START_REGEXP do
      replacements += 1
      attrs = $LAST_MATCH_INFO[:attrs]

      "<div class='b-quote' data-attrs='#{ERB::Util.h attrs}'><div class='quoteable'>" +
        BbCodes::Quotes::QuoteableToBbcode.instance.call(
          topic_id: $LAST_MATCH_INFO[:topic_id],
          user_id: $LAST_MATCH_INFO[:user_id],
          nickname: $LAST_MATCH_INFO[:nickname]
        ) +
        "</div><div class='quote-content'>"
    end

    [result, replacements, original_text]
  end

  def simple_quote_2 text, replacements, original_text
    result = text.gsub SIMPLE_QUOTE_2_START_REGEXP do
      replacements += 1
      attrs = $LAST_MATCH_INFO[:attrs]

      "<div class='b-quote' data-attrs='#{ERB::Util.h attrs}'><div class='quoteable'>" +
        BbCodes::Quotes::QuoteableToBbcode.instance.call(
          nickname: $LAST_MATCH_INFO[:nickname]
        ) +
        "</div><div class='quote-content'>"
    end

    [result, replacements, original_text]
  end

  def simple_quote_1 text, replacements, original_text
    result = text.gsub SIMPLE_QUOTE_1_START_REGEXP do
      replacements += 1
      "<div class='b-quote'><div class='quote-content'>"
    end

    [result, replacements, original_text]
  end

  def quote_end text, replacements, original_text
    result = text.gsub QUOTE_END_REGEXP do
      replacements -= 1
      '</div></div>'
    end

    if replacements.zero?
      result
    else
      original_text
    end
  end
end
# rubocop:enable ClassLength
