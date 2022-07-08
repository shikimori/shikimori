class Topics::NewsLineView < Topics::View
  instance_cache :view

  delegate :poster,
    :topic_title,
    :topic_title_html,
    to: :view

  def container_classes additional = []
    ['b-news_line-topic', *additional]
  end

  def url
    if topic_type_policy.contest_topic?
      h.contest_url @topic.linked
    # elsif topic_type_policy.article_topic?
    #   h.article_url @topic.linked
    # elsif topic_type_policy.collection_topic?
    #   h.collection_url @topic.linked
    else
      super
    end
  end

  def view
    Topics::TopicViewFactory.new(@is_preview, @is_mini).build @topic
  end

  def action_tag
    view.action_tag.presence || super(
      OpenStruct.new(
        type: 'other',
        text: db_entry_topic? ? @topic.title.downcase : i18n_i('topic', :one)
      )
    )
  end

  def db_entry_topic?
    @topic.class < Topics::EntryTopic
  end
end
