class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  EVIL_CSS = [
    # suspicious javascript-type words
    /(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i,
    /behaviou?r|expression|moz-binding|@import|@charset/i,
    /(java|vb)?script|[\<]|\\\w/i,
    # back slash, html tags,
    /[\<>]/,
    # high bytes -- suspect
    # /[\x7f-\xff]/,
    #low bytes -- suspect
    /[\x00-\x08\x0B\x0C\x0E-\x1F]/,
    /&\#/, # bad charset
  ]

  def call
    sanitized_css = css
    EVIL_CSS.each { |regex| sanitized_css = sanitized_css.gsub regex, '' }
    sanitized_css
  end
end
