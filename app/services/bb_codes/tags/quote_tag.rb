# rubocop:disable ClassLength
class BbCodes::Tags::QuoteTag
  include Singleton

  COMMENT_QUOTE_START_REGEXP = /
    \[quote=
      c?(?<comment_id>\d+);
      \d+;
      (?<nickname>[^\]]+)
    \]
  /mix

  MESSAGE_QUOTE_START_REGEXP = /
    \[quote=
      m(?<message_id>\d+);
      \d+;
      (?<nickname>[^\]]+)
    \]
  /mix

  TOPIC_QUOTE_START_REGEXP = /
    \[quote=
      t(?<topic_id>\d+);
      \d+;
      (?<nickname>[^\]]+)
    \]
  /mix

  SIMPLE_QUOTE_1_START_REGEXP = /
    \[quote\]
  /mix

  SIMPLE_QUOTE_2_START_REGEXP = /
    \[quote=(?<nickname>[^\]]+)\]
  /mix

  QUOTE_END_REGEXP = %r{
    \[/quote\]
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
        text
      ))))))
  end

private

  def comment_quote text, replacements, original_text
    result = text.gsub COMMENT_QUOTE_START_REGEXP do
      replacements += 1

      '<div class="b-quote"><div class="quoteable">'\
        "[comment=#{$LAST_MATCH_INFO[:comment_id]} quote]"\
        "#{$LAST_MATCH_INFO[:nickname]}[/comment]"\
        '</div>'
    end

    [result, replacements, original_text]
  end

  def message_quote text, replacements, original_text
    result = text.gsub MESSAGE_QUOTE_START_REGEXP do
      replacements += 1
      '<div class="b-quote"><div class="quoteable">'\
        "[message=#{$LAST_MATCH_INFO[:message_id]} quote]"\
        "#{$LAST_MATCH_INFO[:nickname]}[/message]"\
        '</div>'
    end

    [result, replacements, original_text]
  end

  def topic_quote text, replacements, original_text
    result = text.gsub TOPIC_QUOTE_START_REGEXP do
      replacements += 1
      '<div class="b-quote"><div class="quoteable">'\
        "[topic=#{$LAST_MATCH_INFO[:topic_id]} quote]"\
        "#{$LAST_MATCH_INFO[:nickname]}[/topic]"\
        '</div>'
    end

    [result, replacements, original_text]
  end

  def simple_quote_2 text, replacements, original_text
    result = text.gsub SIMPLE_QUOTE_2_START_REGEXP do
      replacements += 1
      '<div class="b-quote"><div class="quoteable">'\
        "[user]#{$LAST_MATCH_INFO[:nickname]}[/user]"\
        '</div>'
    end

    [result, replacements, original_text]
  end

  def simple_quote_1 text, replacements, original_text
    result = text.gsub SIMPLE_QUOTE_1_START_REGEXP do
      replacements += 1
      '<div class="b-quote">'
    end

    [result, replacements, original_text]
  end

  def quote_end text, replacements, original_text
    result = text.gsub QUOTE_END_REGEXP do
      replacements -= 1
      '</div>'
    end

    if replacements.zero?
      result
    else
      original_text
    end
  end
end
# rubocop:enable ClassLength
