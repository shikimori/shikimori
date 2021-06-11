class BbCodes::Tags::ImageTag # rubocop:disable ClassLength
  include Singleton

  DELETED_MARKER = 'deleted'
  DELETED_IMAGE_PATH = '/assets/globals/missing_main.png'
  DELETED_IMAGE_HTML = "<img src='#{DELETED_IMAGE_PATH}' loading='lazy' />"

  OPTIONS_REGEXP = /
    (?:
      (?: \s c(?:lass)?=(?<css_class>[\w_-]+) )? |
      (?: \s (?<width>\d+)x(?<height>\d+) )? |
      (?: \s w(?:idth)?=(?<width>\d+) )? |
      (?: \s h(?:eight)?=(?<height>\d+) )? |
      (?<no_zoom> \s no-zoom )?
    )*
  /xi

  REGEXP = /
    \[
      image=(?<id>\d+|#{DELETED_MARKER})
      #{OPTIONS_REGEXP.source}
    \]
  /xi

  def format text, text_hash # rubocop:disable MethodLength
    text.gsub REGEXP do |matched|
      if $LAST_MATCH_INFO[:id] == DELETED_MARKER
        DELETED_IMAGE_HTML

      elsif (user_image = UserImage.find_by(id: $LAST_MATCH_INFO[:id]))
        attrs = build_attrs(
          user_image: user_image,
          width: $LAST_MATCH_INFO[:width].to_i,
          height: $LAST_MATCH_INFO[:height].to_i,
          is_no_zoom: $LAST_MATCH_INFO[:no_zoom].present?,
          css_class: $LAST_MATCH_INFO[:css_class]
        )

        html_for user_image: user_image, attrs: attrs, text_hash: text_hash
      else

        not_found_to_html matched
      end
    end
  end

private

  def html_for user_image:, attrs:, text_hash:
    marker_html = marker_html user_image, attrs[:isNoZoom]

    if attrs[:isNoZoom]
      small_image_html(
        user_image: user_image,
        attrs: attrs,
        marker_html: marker_html
      )
    else
      large_image_html(
        user_image: user_image,
        attrs: attrs,
        marker_html: marker_html,
        text_hash: text_hash
      )
    end
  end

  def small_image_html user_image:, attrs:, marker_html:
    original_url = ImageUrlGenerator.instance.url user_image, :original
    sizes_html = sizes_html attrs

    <<-HTML.squish.strip
      <span class='b-image
        no-zoom#{" #{attrs[:class]}" if attrs[:class]}'
        data-attrs='#{ERB::Util.h attrs.to_json}'><img
        src='#{ERB::Util.h original_url}' #{sizes_html}#{" class='check-width'" if sizes_html.blank?}
        loading='lazy' />#{marker_html}</span>
    HTML
  end

  def large_image_html user_image:, attrs:, marker_html:, text_hash:
    original_url = ImageUrlGenerator.instance.url user_image, :original
    preview_url = ImageUrlGenerator.instance.url(
      user_image,
      attrs[:width] || attrs[:height] ? :preview : :thumbnail
    )

    <<-HTML.squish.strip
      <a
        href='#{ERB::Util.h original_url}'
        rel='#{text_hash}'
        class='b-image
        unprocessed#{" #{ERB::Util.h attrs[:class]}" if attrs[:class]}'
        data-attrs='#{ERB::Util.h attrs.to_json}'><img
        src='#{preview_url}' #{sizes_html attrs}
        data-width='#{user_image.width}'
        data-height='#{user_image.height}'
        loading='lazy'
      />#{marker_html}</a>
    HTML
  end

  def not_found_to_html string
    "<span class='b-entry-404'><del>#{string}</del></span>"
  end

  def build_attrs user_image:, width:, height:, is_no_zoom:, css_class:
    attrs = {
      id: user_image.id,
      width: (width if width.positive?),
      height: (height if height.positive?),
      isNoZoom: is_no_zoom || small_image?(user_image) ? true : nil,
      class: css_class
    }.compact

    scale_sizes attrs, user_image if attrs[:width] && attrs[:height]

    attrs
  end

  def scale_sizes attrs, user_image
    ratio = (1.0 * user_image.width / user_image.height).round(2)
    scaled_width = [700, attrs[:width], user_image.width].min
    scaled_height = (1.0 * attrs[:width] / attrs[:height]).round(2) == ratio ?
      attrs[:height] :
      (scaled_width / ratio).to_i

    attrs[:width] = scaled_width
    attrs[:height] = scaled_height
  end

  def small_image? user_image
    user_image.width <= 250 && user_image.height <= 250
  end

  def sizes_html data_attrs
    if data_attrs[:width] && data_attrs[:height]
      "width='#{data_attrs[:width]}' height='#{data_attrs[:height]}'"

    elsif data_attrs[:width]
      "width='#{data_attrs[:width]}'"

    elsif data_attrs[:height]
      "height='#{data_attrs[:height]}'"
    end
  end

  def marker_html user_image, is_no_zoom
    return if small_image?(user_image) || is_no_zoom

    <<-HTML.squish.strip
      <span class='marker'>#{user_image.width}x#{user_image.height}</span>
    HTML
  end
end
