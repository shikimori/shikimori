class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  EVIL_CSS = [
    # suspicious javascript-type words
    /(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i,
    /behaviou?r|expression|moz-binding|@charset/i,
    /(java|vb)?script|<|\\\w/i,
    # back slash, html tags,
    # /[\<>]/,
    /</,
    # high bytes -- suspect
    # /[\x7f-\xff]/,
    # low bytes -- suspect
    /[\x00-\x08\x0B\x0C\x0E-\x1F]/,
    /&\#/ # bad charset
  ]

  IMPORTS_REGEXP = /
    @import \s+ url \( ['"]? (?<url>.*?) ['"]? \);?
    [\n\r]*
  /mix

  def call
    EVIL_CSS
      .inject(@css) { |styles, regex| styles.gsub(regex, '') }
      .gsub(IMPORTS_REGEXP, '')
    # Sanitize::CSS.stylesheet(
    #   (EVIL_CSS.inject(@css) { |styles, regex| styles.gsub(regex, '') }),
    #   Sanitize::Config::RELAXED
    # )
  end
end
