class Topics::Urls < ViewObjectBase
  pattr_initialize :view
  delegate :topic, :is_preview, to: :view

  def poster_url
    if is_preview
      topic_url
    else
      h.profile_url topic.user
    end
  end

  def body_url
    h.entry_body_url topic
  end

  def edit_url
    if topic_type_policy.critique_topic?
      h.send "edit_#{topic.linked.target_type.downcase}_critique_url",
        topic.linked.target, topic.linked

    elsif topic_type_policy.collection_topic?
      h.edit_collection_url topic.linked

    elsif topic_type_policy.article_topic?
      h.edit_article_url topic.linked

    elsif topic_type_policy.club_page_topic?
      h.edit_club_club_page_path topic.linked.club, topic.linked

    else
      h.edit_topic_url topic
    end
  end

  def destroy_url
    if topic_type_policy.critique_topic?
      h.send "#{topic.linked.target_type.downcase}_critique_url",
        topic.linked.target, topic.linked

    elsif topic_type_policy.collection_topic?
      h.collection_url topic.linked

    elsif topic_type_policy.article_topic?
      h.article_url topic.linked

    else
      h.topic_path topic
    end
  end

  def subscribe_url
    h.subscribe_url type: topic.class.name, id: topic.id
  end

  def topic_url options = {}
    @view.url options
  end

  def topic_type_policy
    @topic_type_policy ||= Topic::TypePolicy.new @view.topic
  end
end
