class Topics::CosplayView < Topics::View
  def container_class
    super 'b-cosplay'
  end

  def render_body
    h.render 'topics/cosplay/info', view: self, gallery: topic.linked
  end

  def action_tag
    OpenStruct.new(
      type: 'cosplay',
      text: h.t('cosplay').downcase
    )
  end

  def topic_title
    if !is_preview
      topic.user.nickname
    else
      topic.linked.title
    end
  end

  def poster is_2x
    topic.user.avatar_url is_2x ? 80 : 48
  end
end
