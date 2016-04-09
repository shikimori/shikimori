class BbCodes::ImgTag
  include Singleton

  REGEXP = /
      \[url=(?<link_url>[^\[\]]+)\]
        \[img\]
          (?<image_url>[^\[\]].*?)
        \[\/img\]
      \[\/url\]
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
        (?<image_url>[^\[\]].*?)
      \[\/img\]
  /imx

  def format text, text_hash
    text.gsub REGEXP do
      if $~[:link_url]
        html_for_image $~[:image_url], $~[:link_url], 0, 0, nil, text_hash
      else
        html_for_image $~[:image_url], nil, $~[:width].to_i, $~[:height].to_i, $~[:klass], text_hash
      end
    end
  end

private

  def html_for_image image_url, link_url, width, height, klass, text_hash
    camo_url = UrlGenerator.instance.camo_url(image_url)

    sizes_html = ''
    sizes_html += " width=\"#{width}\"" if width > 0
    sizes_html += " height=\"#{height.to_i}\"" if height > 0

    "<a href=\"#{link_url || image_url}\" data-href=\"#{camo_url}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{camo_url}\" class=\"#{'check-width' unless sizes_html.present?}\
#{' '+klass if klass.present?}\"#{sizes_html}></a>"
  end
end
