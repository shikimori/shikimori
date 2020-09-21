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
    \] \n?
  }mix

  FORBIDDEN_CLASSES = %w[
    l-menu
    l-page
    l-footer
    l-top_menu-v2
    b-comments-notifier
    b-achievements_notifier
    b-fancy_loader
    b-comments
    b-feedback
    b-to-top
    b-height_shortener
    b-new_marker
    b-appear_marker
    shade
    expand
    menu-slide-outer
    menu-slide-inner
    menu-toggler
    turbolinks-progress-bar
    b-admin_panel
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

      inner = class_html($LAST_MATCH_INFO[:css_class]) +
        data_html($LAST_MATCH_INFO[:data_attributes])

      "<div#{inner} data-div>"
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

  def class_html value
    if value.present?
      " class=\"#{cleanup value}\""
    else
      ''
    end
  end

  def data_html value
    value.presence || ''
  end

  def cleanup css_classes
    css_classes
      .gsub(CLEANUP_CLASSES_REGEXP, '')
      .gsub(/\s\s+/, '')
      .strip
  end
end
