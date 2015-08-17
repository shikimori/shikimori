class BbCodes::ImageTag
  include Singleton
  REGEXP = /
    \[
      image (?:=(?<id>\d+))
      (?:
        (?: \s c(?:lass)?=(?<klass>[\w_-]+) )? |
        (?: \s (?<width>\d+)x(?<height>\d+) )? |
        (?: \s w(?:idth)?=(?<width>\d+) )? |
        (?: \s h(?:eight)?=(?<height>\d+) )?
      )*
    \]
  /xi

  def format text, text_hash
    text.gsub REGEXP do |matched|
      user_image = UserImage.find_by(id: $~[:id])

      if user_image
        html_for user_image, $~[:width].to_i, $~[:height].to_i, $~[:klass], text_hash
      else
        matched
      end
    end
  end

private

  def html_for user_image, width, height, klass, text_hash
    if user_image.width <= 250 && user_image.height <= 250
      if klass
        "<img src=\"#{ImageUrlGenerator.instance.url user_image, :original}\" class=\"#{klass}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />"
      else
        "<img src=\"#{ImageUrlGenerator.instance.url user_image, :original}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />"
      end

    else
      sizes_html = if width > 0 && height > 0
        ratio = 1.0 * user_image.width / user_image.height
        width = [700, width, user_image.width].min
        height = (width / ratio).to_i if 1.0 * width / height != ratio
        " width=\"#{width}\" height=\"#{height}\""

      elsif width > 0
        " width=\"#{width}\""

      elsif height > 0
        " height=\"#{height.to_i}\""

      else
        nil
      end

      "<a href=\"#{ImageUrlGenerator.instance.url user_image, :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{ImageUrlGenerator.instance.url user_image, sizes_html ? :preview : :thumbnail}\" \
class=\"#{klass if klass}\"#{sizes_html} \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">#{user_image.width}x#{user_image.height}</span></a>"
    end
  end
end
