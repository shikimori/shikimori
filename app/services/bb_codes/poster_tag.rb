class BbCodes::PosterTag
  include Singleton

  REGEXP = /
    \[poster\]
      (?<url>[^\[\]].*?)
    \[\/poster\]
  /imx

  def format text
    text.gsub REGEXP do
      html_for_image $~[:url]
    end
  end

private
  def html_for_image url
    "<img class=\"b-poster\" src=\"#{url}\" />"
  end
end
