class BbCodes::CleanupCssClass
  method_object :value

  FORBIDDEN_CSS_CLASSES = %w[
    b-achievements_notifier
    b-admin_panel
    b-appear_marker
    b-comments-notifier
    b-comments
    b-fancy_loader
    b-feedback
    b-height_shortener
    b-modal
    b-new_marker
    b-to-top
    ban
    expand
    l-footer
    l-menu
    l-page
    l-top_menu-v2
    menu-slide-inner
    menu-slide-outer
    menu-toggler
    mfp-bg
    mfp-container
    mfp-coub
    mfp-webm-holder
    mfp-wrap
    shade
    turbolinks-progress-bar
  ]

  CLEANUP_REGEXP = /
    #{FORBIDDEN_CSS_CLASSES.join '|'} |
    \bl-(?<css_class>[\w_\- ]+)
  /mix

  def call
    return @value if @value.blank?

    result = @value.gsub(CLEANUP_REGEXP, '').gsub(/\s\s+/, ' ').strip
    return '' if result.match? CLEANUP_REGEXP

    ERB::Util.h result
  end
end
