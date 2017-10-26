class BbCodes::Tags::DivTag
  include Singleton

  TAG_START_REGEXP = /
    \[
      div
      (?: =(?<css_class>[\w_\ \-]+) )?
    \]
  /mix

  TAG_END_REGEXP = %r{
    \[
      /div
    \]
  }mix

  FORBIDDEN_CLASSES = %w[
    b-comments-notifier
    b-comments
    b-feedback
    b-to-top
    b-height_shortener
    shade
    expand
    menu-slide-outer
    menu-slide-inner
    menu-toggler
    to-top-fix
  ]
  CLEANUP_CLASSES_REGEXP = /
    #{FORBIDDEN_CLASSES.join '|'} |
    \bl-(?<css_class>[\w_\-]+)
  /mix

  def format text
    return text unless text.include?('[/div]')

    div_end(*div_start(text, 0, text))
  end

private

  def div_start text, replacements, original_text
    result = text.gsub TAG_START_REGEXP do
      replacements += 1

      if $LAST_MATCH_INFO[:css_class]
        "<div class=\"#{cleanup $LAST_MATCH_INFO[:css_class]}\">"
      else
        '<div>'
      end
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

  def cleanup css_classes
    css_classes
      .gsub(CLEANUP_CLASSES_REGEXP, '')
      .gsub(/\s\s+/, '')
      .strip
  end
end
