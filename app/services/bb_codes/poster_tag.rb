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

  def html_for_url url
    "<img class=\"b-poster\" src=\"#{url}\" />"
  end

  def html_for_image user_image
    "<img class=\"b-poster\" src=\"#{user_image.image.url :original, false}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />"
  end
end
