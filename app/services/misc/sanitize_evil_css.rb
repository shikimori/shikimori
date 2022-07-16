class Misc::SanitizeEvilCss < ServiceObjectBase
  pattr_initialize :css

  def self.w word
    word.split(//).map { |symbol| "\\\\?#{symbol}" }.join
  end

  COMMENTS_REGEXP = %r{
    /\* .*? \*/ \s* [\n\r]*
  }mix
  IMPORTS_REGEXP = /
    (?:
     @*import \s+ url \( ['"]? .*? ['"]? \); |
     @*import \s+ ['"] .*? ['"] |
     #{w '@'}+#{w 'import'}
    )\ ?[\n\r]*
  /mix

  EVIL_WORDS = /
    \b (?:
      #{w 'eval'} |
      #{w 'cookie'} |
      #{w 'window'} |
      #{w 'parent'} |
      #{w 'this'} |
      #{w 'javascript'} |
      #{w 'vbscript'} |
      #{w 'script'} |
      #{w 'behavior'} |
      #{w 'behaviour'} |
      #{w 'expression'}
    ) \b |
    #{w 'moz-binding'} |
    #{w '@'}*#{w 'charset'} |
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
  FIX_CONTENT_REGEXP = /(content: ?['"]\\)\\.?(\w{4}['"])/
  DATA_IMAGE_REGEXP = %r{
    (?: \b|^ )
    (?:
      (
        (?>data:(?:
          image/(?:svg\+xml|png|jpeg|jpg|gif) |
          application/octet-stream
        );base64,)
      )
      | #{w 'data:'}(?:\b|$)
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
    css
      .gsub(FIX_CONTENT_REGEXP, '\1\2')
  end
end

# @_ url(content:'); @\import "https://dl.dropboxusercontent.com/s/sk5j2w5ysaj10u8/shiki_test_import.css";
# /* AUTO=sticky_menu */ @media screen {}
