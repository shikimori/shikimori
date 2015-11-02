class Topics::CosplayView < Topics::View
  IMAGES_IN_PREVIEW = 7

  def container_class
    super 'b-cosplay-topic'
  end

  def minified?
    is_preview || is_mini
  end

  def render_body
    h.render 'topics/cosplay/info', view: self, gallery: topic.linked
  end

  def poster is_2x
    topic.user.avatar_url is_2x ? 80 : 48
  end

  def topic_title
    if !minified?
      topic.user.nickname
    else
      topic.linked.title
    end
  end

  def html_body_truncated
    render_body
  end

  def html_footer
    if is_preview
      BbCodeFormatter.instance.format_comment "[wall]#{images_bb_codes}[/wall]"
    end
  end

  def action_tag
    OpenStruct.new(
      type: 'cosplay',
      text: h.t('cosplay').downcase
    ) if minified?
  end

  def images_bb_codes
    topic.linked.images.limit(IMAGES_IN_PREVIEW).each.map do |image|
      "[url=#{ImageUrlGenerator.instance.url image, :original}][img]#{ImageUrlGenerator.instance.url image, :preview}[/img][/url]"
    end.join('')
  end
end
