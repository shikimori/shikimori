class BbCodes::ImgTag
  include Singleton

  REGEXP = /
    \[
      img
      (?:
        (?: \s c(?:lass)?=(?<klass>[\w_-]+) )? |
        (?: \s (?<width>\d+)x(?<height>\d+) )? |
        (?: \s w(?:idth)?=(?<width>\d+) )? |
        (?: \s h(?:eight)?=(?<height>\d+) )?
      )*
    \]
      (?<url>[^\[\]].*?)
    \[\/img\]
  /imx

  def format text, text_hash
    text.gsub REGEXP do
      html_for $~[:url], $~[:width].to_i, $~[:height].to_i, $~[:klass], text_hash
    end
  end

private
  def html_for url, width, height, klass, text_hash
    sizes_html = ''

    sizes_html += " width=\"#{width}\"" if width > 0
    sizes_html += " height=\"#{height.to_i}\"" if height > 0

    "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width#{" #{klass}" if klass}\"#{sizes_html}/></a>"
  end
end
