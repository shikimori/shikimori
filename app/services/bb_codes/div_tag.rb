class BbCodes::DivTag
  include Singleton

  TAG_START_REGEXP = /
    \[div=(?<css_class>[\w_\ \-]+)\]
  /mix

  TAG_END_REGEXP = %r{
    \[/div\]
  }mix

  def format text
    return text unless text.include?('[/div]')

    div_end(*div_start(text, 0, text))
  end

private

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
