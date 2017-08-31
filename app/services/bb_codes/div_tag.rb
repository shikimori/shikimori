class BbCodes::DivTag
  include Singleton

  TAG_START_REGEXP = /
    \[div=(?<css_class>[\w_\ \-]+)\]
  /mix

  TAG_END_REGEXP = %r{
    \[/div\]
  }mix

  TAG_START_NEW_LINES_1_REGEXP = %r{
    (?<first>#{TAG_START_REGEXP.source})
    [\n\r\ ]+
    (?<second>#{TAG_START_REGEXP.source})
  }mix

  TAG_START_NEW_LINES_2_REGEXP = %r{
    (?<first>#{TAG_START_REGEXP.source})
    [\n\r]
  }mix

  TAG_END_START_NEW_LINES_REGEXP = %r{
    (?<first>#{TAG_END_REGEXP.source})
    [\n\r\ ]+
    (?<second>#{TAG_START_REGEXP.source})
  }mix

  TAG_END_NEW_LINES_REGEXP_1 = %r{
    [\n\r]*
    (#{TAG_END_REGEXP.source})
  }mix

  TAG_END_NEW_LINES_REGEXP_2 = %r{
    (#{TAG_END_REGEXP.source})
    [\n\r\ ]+
    (#{TAG_END_REGEXP.source})
  }mix

  def format text
    return text unless text.include?('[/div]')

    div_end(*div_start(*cleanup_new_lines(text, 0, text)))
  end

private

  def cleanup_new_lines text, replacements, original_text
    result = text
      .gsub TAG_START_NEW_LINES_1_REGEXP do
        "#{$LAST_MATCH_INFO[:first]}#{$LAST_MATCH_INFO[:second]}"
      end
      .gsub TAG_START_NEW_LINES_2_REGEXP do
        "#{$LAST_MATCH_INFO[:first]}"
      end
      .gsub TAG_END_START_NEW_LINES_REGEXP do
        "#{$LAST_MATCH_INFO[:first]}#{$LAST_MATCH_INFO[:second]}"
      end
      .gsub(TAG_END_NEW_LINES_REGEXP_1, '\1')
      .gsub(TAG_END_NEW_LINES_REGEXP_2, '\1\2')

    [result, replacements, original_text]
  end

  def div_start text, replacements, original_text
    result = text.gsub TAG_START_REGEXP do
      replacements += 1
      "<div class=\"#{$LAST_MATCH_INFO[:css_class]}\">"
    end

    [result, replacements, original_text]
  end

  def div_end text, replacements, original_text
    result = text.gsub TAG_END_REGEXP do
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
