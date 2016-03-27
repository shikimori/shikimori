class BbCodes::PosterTag
  include Singleton

  REGEXP = /
      \[poster\]
        (?<url>[^\[\]].*?)
      \[\/poster\]
    |
      \[poster (?:=(?<id>\d+))\]
  /imx

  def format text
    text.gsub REGEXP do |matched|
      if $~[:url]
        html_for_url $~[:url]
      else
        user_image = UserImage.find_by(id: $~[:id])
        user_image ? html_for_image(user_image) : matched
      end
    end
  end

private

  def html_for_url image_url
    camo_url = UrlGenerator.instance.camo_url(image_url)
    "<img class=\"b-poster\" src=\"#{camo_url}\" />"
  end

  def html_for_image user_image
    url = ImageUrlGenerator.instance.url user_image, :original
    "<img class=\"b-poster\" src=\"#{url}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />"
  end
end
