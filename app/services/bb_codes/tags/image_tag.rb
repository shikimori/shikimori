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
        (?: \s h(?:eight)?=(?<height>\d+) )? |
        (?<no_zoom> \s no-zoom )?
      )*
    \]
  /xi

  def format text, text_hash # rubocop:disable MethodLength
    text.gsub REGEXP do |matched|
      if $LAST_MATCH_INFO[:id] == DELETED_MARKER
        DELETED_IMAGE_HTML

      elsif (user_image = UserImage.find_by(id: $LAST_MATCH_INFO[:id]))
        html_for(
          user_image: user_image,
          width: $LAST_MATCH_INFO[:width].to_i,
          height: $LAST_MATCH_INFO[:height].to_i,
          css_class: $LAST_MATCH_INFO[:css_class],
          is_no_zoom: $LAST_MATCH_INFO[:no_zoom].present?,
          text_hash: text_hash
        )
      else
        matched
      end
    end
  end

private

  def html_for( # rubocop:disable ParameterLists, MethodLength
    user_image:,
    width:,
    height:,
    css_class:,
    is_no_zoom:,
    text_hash:
  )
    sizes_html = sizes_html user_image, width, height
    marker_html = marker_html user_image, is_no_zoom

    if is_no_zoom || small_image?(user_image)
      small_image_html(
        user_image: user_image,
        sizes_html: sizes_html,
        marker_html: marker_html,
        css_class: css_class
      )
    else
      large_image_html(
        user_image: user_image,
        sizes_html: sizes_html,
        marker_html: marker_html,
        css_class: css_class,
        text_hash: text_hash
      )
    end
  end

  def small_image_html user_image:, sizes_html:, marker_html:, css_class:
    original_url = ImageUrlGenerator.instance.url user_image, :original

    <<-HTML.squish.strip
      <span class="b-image no-zoom#{" #{css_class}" if css_class.present?}"><img
        src="#{original_url}" #{sizes_html}#{' class="check-width"' unless sizes_html.present?}
      />#{marker_html}</span>
    HTML
  end

  def large_image_html user_image:, sizes_html:, marker_html:, css_class:, text_hash:
    original_url = ImageUrlGenerator.instance.url user_image, :original
    preview_url = ImageUrlGenerator.instance.url(
      user_image,
      sizes_html ? :preview : :thumbnail
    )

    <<-HTML.squish.strip
      <a
        href="#{original_url}"
        rel="#{text_hash}"
        class="b-image unprocessed#{" #{css_class}" if css_class.present?}"><img
        src="#{preview_url}" #{sizes_html}
        data-width="#{user_image.width}"
        data-height="#{user_image.height}"
      />#{marker_html}</a>
    HTML
  end

  def sizes_html user_image, width, height
    if width.positive? && height.positive?
      ratio = 1.0 * user_image.width / user_image.height
      scaled_width = [700, width, user_image.width].min
      scaled_height = 1.0 * width / height != ratio ? (scaled_width / ratio).to_i : height

      "width=\"#{scaled_width}\" height=\"#{scaled_height}\""

    elsif width.positive?
      "width=\"#{width}\""

    elsif height.positive?
      "height=\"#{height}\""
    end
  end

  def small_image? user_image
    user_image.width <= 250 && user_image.height <= 250
  end

  def marker_html user_image, is_no_zoom
    return if small_image?(user_image) || is_no_zoom

    <<-HTML.squish.strip
      <span class="marker">#{user_image.width}x#{user_image.height}</span>
    HTML
  end
end
