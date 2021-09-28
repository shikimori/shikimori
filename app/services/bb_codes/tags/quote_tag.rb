# rubocop:disable ClassLength
class BbCodes::Tags::QuoteTag
  include Singleton

  FORUM_ENTRY_QUOTE_START_REGEXP = /
    \[quote=
      (?<attrs>
        (:?
          m(?<message_id>\d+) |
          t(?<topic_id>\d+) |
          r(?<review_id>\d+) |
          c?(?<comment_id>\d+)
        );
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
      forum_entry_quote(*
        text,
        0,
        text))))
  end

private

  def forum_entry_quote text, replacements, original_text
    result = text.gsub FORUM_ENTRY_QUOTE_START_REGEXP do
      replacements += 1
      attrs = $LAST_MATCH_INFO[:attrs]

      "<div class='b-quote' data-attrs='#{ERB::Util.h attrs}'><div class='quoteable'>" +
        BbCodes::Quotes::QuoteableToBbcode.instance.call(
          comment_id: $LAST_MATCH_INFO[:comment_id],
          message_id: $LAST_MATCH_INFO[:message_id],
          topic_id: $LAST_MATCH_INFO[:topic_id],
          review_id: $LAST_MATCH_INFO[:review_id],
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
