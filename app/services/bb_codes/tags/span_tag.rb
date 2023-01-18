class BbCodes::Tags::SpanTag
  include Singleton

  TAG_START_REGEXP = /
    \[
      span
      (?: =(?<css_class>(?:[\w_\ -](?!data-\w))+) )?
      (?<data_attributes>(?:\ data-[\w_-]+(?:=[\w_-]+)?)+)?
    \]
  /mix

  TAG_END_REGEXP = %r{
    \[
      /span
    \]
  }mix

  def format text
    return text unless text.include?('[/span]')

    span_end(*span_start(text, 0, text))
  end

private

  def span_start text, replacements, original_text
    result = text.gsub TAG_START_REGEXP do
      replacements += 1

      inner = class_html($LAST_MATCH_INFO[:css_class]) +
        data_html($LAST_MATCH_INFO[:data_attributes])

      "<span#{inner} data-span>"
    end

    [result, replacements, original_text]
  end

  def span_end text, replacements, original_text
    result = text.gsub TAG_END_REGEXP do
      replacements -= 1
      '</span>'
    end

    if replacements.zero?
      result
    else
      original_text
    end
  end

  def class_html value
    if value.present?
      " class=\"#{BbCodes::CleanupCssClass.call(value)}\""
    else
      ''
    end
  end

  def data_html value
    value.presence || ''
  end
end
