class BbCodes::Tags::DivTag
  include Singleton

  TAG_START_REGEXP = /
    \[
      div
      (?: =(?<css_class>(?:[\w_\ \-](?!data-\w))+) )?
      (?<data_attributes>(?:\ data-[\w_\-]+(?:=[\w_\-]+)?)+)?
    \] \n?
  /mix

  TAG_END_REGEXP = %r{
    \n? \[
      /div
    \]
    (?<other_closed_tags>
      (?:
        [\[<] / (?!div) \w+ [\]>]
      )*
    ) \n?
  }mix

  def format text
    return text unless text.include?('[/div]')

    div_end(*div_start(text, 0, text))
  end

private

  def div_start text, replacements, original_text
    result = text.gsub TAG_START_REGEXP do
      replacements += 1

      inner = class_html($LAST_MATCH_INFO[:css_class]) +
        data_html($LAST_MATCH_INFO[:data_attributes])

      "<div#{inner} data-div>"
    end

    [result, replacements, original_text]
  end

  def div_end text, replacements, original_text
    result = text.gsub TAG_END_REGEXP do
      replacements -= 1
      "</div>#{$LAST_MATCH_INFO[:other_closed_tags]}"
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
