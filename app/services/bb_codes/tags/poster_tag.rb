class BbCodes::Tags::PosterTag
  include Singleton

  DELETED_MARKER = BbCodes::Tags::ImageTag::DELETED_MARKER
  DELETED_IMAGE_HTML = BbCodes::Tags::ImageTag::DELETED_IMAGE_HTML

  REGEXP = %r{
    \[poster\]
      (?<url>#{BbCodes::Tags::UrlTag::URL_SYMBOL_CLASS}.*?)
    \[/poster\]

    |

    \[poster (?:=(?<id>\d+|#{DELETED_MARKER}))\]
  }imx

  def format text
    text.gsub REGEXP do |matched|
      if $LAST_MATCH_INFO[:url]
        html_for_url $LAST_MATCH_INFO[:url]

      elsif $LAST_MATCH_INFO[:id] == DELETED_MARKER
        DELETED_IMAGE_HTML

      elsif (user_image = UserImage.find_by(id: $LAST_MATCH_INFO[:id]))
        html_for_image user_image

      else
        matched
      end
    end
  end

private

  def html_for_url image_url
    camo_url = UrlGenerator.instance.camo_url(image_url)
    attrs = { isPoster: true }

    "<span class='b-image b-poster no-zoom' data-attrs='#{attrs.to_json}'>" \
      "<img src='#{camo_url}' loading='lazy' />" \
    '</span>'
  end

  def html_for_image user_image
    url = ImageUrlGenerator.instance.url user_image, :original
    attrs = { id: user_image.id, isPoster: true }

    "<span class='b-image b-poster no-zoom' data-attrs='#{attrs.to_json}'>" \
      "<img src='#{url}' "\
        "data-width='#{user_image.width}' "\
        "data-height='#{user_image.height}' "\
        "loading='lazy' />" \
    '</span>'
  end
end
