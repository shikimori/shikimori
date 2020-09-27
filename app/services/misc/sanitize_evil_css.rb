class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  def self.w word
    word.split(//).map { |symbol| "\\\\?#{symbol}" }.join('')
  end

  COMMENTS_REGEXP = %r{
    /\* .*? \*/ \s* [\n\r]*
  }mix
  IMPORTS_REGEXP = /
    (?: @*import \s+ url \( ['"]? .*? ['"]? \); | #{w '@'}+#{w 'import'} )\ ?[\n\r]*
  /mix

  EVIL_WORDS = /
    #{w 'eval'}\b |
    #{w 'cookie'}\b |
    \b#{w 'window'}\b |
    \b#{w 'parent'}\b |
    \b#{w 'this'}\b |
    #{w 'behavior'} |
    #{w 'behaviour'} |
    #{w 'expression'} |
    #{w 'moz-binding'} |
    #{w '@'}*#{w 'charset'} |
    #{w 'javascript'}\b |
    #{w 'vbscript'}\b |
    #{w 'script'}\b |
    #{w '<'}
  /ix

  EVIL_CSS = [
    EVIL_WORDS,
    # suspicious javascript-type words
    # back slash, html tags,
    # /[\<>]/,
    # high bytes -- suspect
    # /[\x7f-\xff]/,
    # low bytes -- suspect
    /[\x00-\x08\x0B\x0C\x0E-\x1F]+/,
    /&\#/, # bad charset
    COMMENTS_REGEXP,
    IMPORTS_REGEXP
  ]

  SPECIAL_REGEXP = /((?>content: ?['"].*?['"]))|\\\w/
  FIX_CONTENT_REGEXP = /(content: ?['"]\\)\\_(.*?['"])/
  DATA_IMAGE_REGEXP = %r{
    (?: \b|^ )
    (?:
      ((?>data:image/(?:svg\+xml|png|jpeg|jpg|gif);base64,))|#{w 'data:'}(?:\b|$)
    )
  }ix

  def call
    fixed_css = fix_content(@css)

    loop do
      fixed_css, is_done = sanitize fixed_css
      break if is_done
    end

    fixed_css.gsub(/;;+/, ';')
  end

private

  def sanitize css
    prior_css = css
    new_css = EVIL_CSS
      .inject(css) { |styles, regex| styles.gsub(regex, '') }
      .gsub(SPECIAL_REGEXP, '\1')
      .gsub(DATA_IMAGE_REGEXP, '\1')
      .strip

    [new_css, new_css == prior_css]
  end

  def fix_content css
    css.gsub(FIX_CONTENT_REGEXP, '\1\2')
  end
end

# @_ url(content:'); @\import "https://dl.dropboxusercontent.com/s/sk5j2w5ysaj10u8/shiki_test_import.css";
# /* AUTO=sticky_menu */ @media screen {}
