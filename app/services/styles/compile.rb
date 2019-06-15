class Styles::Compile
  method_object :css

  MEDIA_QUERY_CSS = '@media only screen and (min-width: 1024px)'

  IMPORTS_REGEXP = /
    @import \s+ url \( ['"]? (?<url>.*?) ['"]? \);
    [\n\r]*
  /mix

  def call
    imports, compiled_css = extract_imports(strip_comments(media_query(sanitize(camo_images(css)))))

    {
      compiled_css: compiled_css,
      imports: imports
    }
  end

private

  def camo_images css
    css.gsub(BbCodes::Tags::UrlTag::URL) do
      url = $LAST_MATCH_INFO[:url]
      if url =~ /(?<quote>["'`])$/
        quote = $LAST_MATCH_INFO[:quote]
        url = url.gsub(/["'`]$/, '')
      end

      "#{UrlGenerator.instance.camo_url url}#{quote}"
    end
  end

  def sanitize css
    Misc::SanitizeEvilCss.call(css).strip.gsub(/;;+/, ';').strip
  end

  def media_query css
    if css.blank? || css.gsub(%r{^/\* AUTO=.*}, '').include?('@media')
      css
    else
      "#{MEDIA_QUERY_CSS} { #{css} }"
    end
  end

  def strip_comments css
    css.gsub(%r{/\* .*? \*/\s*[\n\r]*}mix, '')
  end

  def extract_imports css
    imports = []

    fixed_css = css.gsub(IMPORTS_REGEXP) do
      imports << $LAST_MATCH_INFO[:url]
      nil
    end

    [imports, fixed_css]
  end
end
