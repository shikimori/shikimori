class BbCodes::ImgTag
  include Singleton

  REGEXP = /
      (?<url_start>\[url=[^\[\]]+\])
        \[img\]
          (?<url>[^\[\]].*?)
        \[\/img\]
      (?<url_end>\[\/url\])
    |
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
      if $~[:url_start] && $~[:url_end]
        html_for_linked_image $~[:url], $~[:url_start], $~[:url_end]
      else
        html_for_image $~[:url], $~[:width].to_i, $~[:height].to_i, $~[:klass], text_hash
      end
    end
  end

private
  def html_for_image url, width, height, klass, text_hash
    sizes_html = ''

    sizes_html += " width=\"#{width}\"" if width > 0
    sizes_html += " height=\"#{height.to_i}\"" if height > 0

    "<a href=\"#{url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{url}\" #{"class=\"#{klass}\"" if klass}#{sizes_html}/></a>"
  end

  # TODO: а не выпилить ли этот случай? тогда check-width вообще удалить можно будет вместе с js обработчиком
  def html_for_linked_image url, url_start, url_end
    "#{url_start}<img src=\"#{url}\" class=\"check-width\"/>#{url_end}"
  end
end
