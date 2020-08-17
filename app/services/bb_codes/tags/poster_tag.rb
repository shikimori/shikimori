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

  # rubocop:disable MethodLength
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
  # rubocop:enable MethodLength

private

  def html_for_url image_url
    camo_url = UrlGenerator.instance.camo_url(image_url)

    "<span class='b-image b-poster no-zoom'>" \
      "<img src='#{camo_url}' />" \
    '</span>'
  end

  def html_for_image user_image
    url = ImageUrlGenerator.instance.url user_image, :original

    "<span class='b-image b-poster no-zoom'>" \
      "<img src='#{url}' "\
        "data-width='#{user_image.width}' "\
        "data-height='#{user_image.height}' />" \
    '</span>'
  end
end
