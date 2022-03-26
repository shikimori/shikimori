class Topics::CosplayView < Topics::UserContentView
  IMAGES_IN_PREVIEW = 7

  def container_classes
    super 'b-cosplay-topic'
  end

  def minified?
    preview?
  end

  def html_body
    h.render(
      partial: 'topics/cosplay/info',
      locals: { cosplay_view: self, gallery: topic.linked },
      formats: :html # w/o format it will fail on rss format http://shikimori.local/forum/cosplay.rss
    )
  end

  def html_body_truncated
    html_body
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
    topic
      .linked
      .images
      .limit(IMAGES_IN_PREVIEW)
      .map do |image|
        "[url=#{ImageUrlGenerator.instance.url image, :original}][img]"\
          "#{ImageUrlGenerator.instance.url image, :preview}[/img][/url]"
      end
      .join
  end

  def poster_in_header?
    false
  end
end
