class BbCodes::CleanupCssClass
  method_object :value

  FORBIDDEN_CSS_CLASSES = %w[
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
    ban
  ]

  CLEANUP_REGEXP = /
    #{FORBIDDEN_CSS_CLASSES.join '|'} |
    \bl-(?<css_class>[\w_\- ]+)
  /mix

  def call
    return @value if @value.blank?

    ERB::Util.h(
      @value
        .gsub(CLEANUP_REGEXP, '')
        .gsub(/\s\s+/, ' ')
        .strip
    )
  end
end
