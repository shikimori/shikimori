class BbCodes::Tags::ImageTag
  include Singleton

  DELETED_MARKER = 'deleted'
  DELETED_IMAGE_PATH = '/assets/globals/missing_main.png'
  DELETED_IMAGE_HTML = "<img src=\"#{DELETED_IMAGE_PATH}\" />"

  REGEXP = /
    \[
      image=(?<id>\d+|#{DELETED_MARKER})
      (?:
        (?: \s c(?:lass)?=(?<css_class>[\w_-]+) )? |
        (?: \s (?<width>\d+)x(?<height>\d+) )? |
        (?: \s w(?:idth)?=(?<width>\d+) )? |
        (?: \s h(?:eight)?=(?<height>\d+) )?
      )*
    \]
  /xi

  def format text, text_hash
    text.gsub REGEXP do |matched|
      if $LAST_MATCH_INFO[:id] == DELETED_MARKER
        DELETED_IMAGE_HTML

      elsif (user_image = UserImage.find_by(id: $LAST_MATCH_INFO[:id]))
        html_for(
          user_image: user_image,
          width: $LAST_MATCH_INFO[:width].to_i,
          height: $LAST_MATCH_INFO[:height].to_i,
          css_class: $LAST_MATCH_INFO[:css_class],
          text_hash: text_hash
        )

      else
        matched
      end
    end
  end

private

  def html_for user_image:, width:, height:, css_class:, text_hash:
    if user_image.width <= 250 && user_image.height <= 250
      small_image_html user_image, css_class
    else
      large_image_html(
        user_image: user_image,
        sizes_html: sizes_html(user_image, width, height),
        css_class: css_class,
        text_hash: text_hash
      )
    end
  end

  def small_image_html user_image, css_class
    original_url = ImageUrlGenerator.instance.url user_image, :original

    if css_class
      "<img src=\"#{original_url}\" "\
        "class=\"#{css_class}\" data-width=\"#{user_image.width}\" "\
        "data-height=\"#{user_image.height}\" />"
    else
      "<img src=\"#{original_url}\" data-width=\"#{user_image.width}\" "\
        "data-height=\"#{user_image.height}\" />"
    end
  end

  def large_image_html user_image:, sizes_html:, css_class:, text_hash:
    original_url = ImageUrlGenerator.instance.url user_image, :original
    preview_url = ImageUrlGenerator.instance.url(
      user_image,
      sizes_html ? :preview : :thumbnail
    )

    "<a href=\"#{original_url}\" rel=\"#{text_hash}\" "\
    "class=\"b-image unprocessed\"><img src=\"#{preview_url}\" "\
    "class=\"#{css_class if css_class}\"#{sizes_html} "\
    "data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" "\
    "/>\<span class=\"marker\">#{user_image.width}x#{user_image.height}</span>"\
    '</a>'
  end

  def sizes_html user_image, width, height
    if width.positive? && height.positive?
      ratio = 1.0 * user_image.width / user_image.height
      width = [700, width, user_image.width].min
      height = (width / ratio).to_i if 1.0 * width / height != ratio

      " width=\"#{width}\" height=\"#{height}\""

    elsif width.positive?
      " width=\"#{width}\""

    elsif height.positive?
      " height=\"#{height.to_i}\""
    end
  end
end
