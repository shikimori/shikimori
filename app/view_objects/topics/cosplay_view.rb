class Topics::CosplayView < Topics::UserContentView
  IMAGES_IN_PREVIEW = 7

  def container_class
    super 'b-cosplay-topic'
  end

  def minified?
    true
  end

  def render_body
    h.render 'topics/cosplay/info', cosplay_view: self, gallery: topic.linked
  end

  def poster is_2x
    topic.user.avatar_url is_2x ? 80 : 48
  end

  def html_body_truncated
    render_body
  end

  def html_footer
    if is_preview
      BbCodes::Text.call "[wall]#{images_bb_codes}[/wall]"
    end
  end

  def action_tag
    return unless minified?

    OpenStruct.new(
      type: 'cosplay',
      text: h.t('cosplay').downcase
    )
  end

  def images_bb_codes
    topic.linked.images.limit(IMAGES_IN_PREVIEW).each.map do |image|
      "[url=#{ImageUrlGenerator.instance.url image, :original}][img]"\
        "#{ImageUrlGenerator.instance.url image, :preview}[/img][/url]"
    end.join('')
  end
end
