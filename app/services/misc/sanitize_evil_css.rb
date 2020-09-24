class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  EVIL_CSS = [
    # suspicious javascript-type words
    /(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i,
    /behaviou?r|expression|moz-binding|@charset/i,
    /(java|vb)?script|<|\\\w/i,
    # back slash, html tags,
    # /[\<>]/,
    /<+/,
    # high bytes -- suspect
    # /[\x7f-\xff]/,
    # low bytes -- suspect
    /[\x00-\x08\x0B\x0C\x0E-\x1F]+/,
    /&\#/, # bad charset
    /(?: @*import \s+ url \( ['"]? .*? ['"]? \); | @+import ) ?[\n\r]*/mix # imports
  ]

  def call
    fixed_css = @css

    loop do
      fixed_css, is_done = sanitize fixed_css
      break if is_done
    end

    fixed_css
  end

private

  def sanitize css
    prior_css = css
    new_css = EVIL_CSS.inject(css) { |styles, regex| styles.gsub(regex, '') }.strip

    [new_css, new_css == prior_css]
  end
end
