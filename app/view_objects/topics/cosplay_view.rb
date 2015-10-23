class Topics::CosplayView < Topics::View
  def container_class
    super 'b-cosplay'
  end

  def render_body
    h.render 'topics/cosplay/info', topic: topic, gallery: topic.linked
  end
end
