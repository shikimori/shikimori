class Topics::Urls < ViewObjectBase
  pattr_initialize :topic, :is_preview

  # адрес заголовка топика
  def poster_url
    if is_preview
      h.topic_url topic
    else
      h.profile_url topic.user
    end
  end

  # адрес текста топика
  def body_url
    h.entry_body_url topic
  end

  def edit_url
    if topic.review?
      h.send "edit_#{topic.linked.target_type.downcase}_review_url",
        topic.linked.target, topic.linked
    else
      h.edit_topic_url topic
    end
  end

  def destroy_url
    if topic.review?
      h.send "#{topic.linked.target_type.downcase}_review_url",
        topic.linked.target, topic.linked
    else
      h.topic_path topic
    end
  end

  def subscribe_url
    h.subscribe_url type: topic.class.name, id: topic.id
  end
end
