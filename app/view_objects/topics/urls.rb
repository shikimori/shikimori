class Topics::Urls < ViewObjectBase
  pattr_initialize :view
  delegate :topic, :is_preview, to: :view

  def topic_url options = {}
    @view.url options
  end

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

  def edit_url # rubocop:disable AbcSize
    if topic_type_policy.critique_topic?
      UrlGenerator.instance.edit_critique_url topic.linked

    elsif topic_type_policy.review_topic?
      UrlGenerator.instance.edit_review_url topic.linked

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

  def destroy_url # rubocop:disable AbcSize
    if topic_type_policy.critique_topic?
      UrlGenerator.instance.critique_url topic.linked

    elsif topic_type_policy.review_topic?
      h.api_review_url topic.linked

    elsif topic_type_policy.collection_topic?
      h.collection_url topic.linked

    elsif topic_type_policy.article_topic?
      h.article_url topic.linked

    elsif topic_type_policy.club_page_topic?
      raise ArgumentErorr

    else
      h.topic_path topic
    end
  end

  def subscribe_url
    h.subscribe_url type: topic.class.name, id: topic.id
  end

  def topic_type_policy
    @topic_type_policy ||= Topic::TypePolicy.new @view.topic
  end

private

  # def build_critique_url action = nil
  #   action_path = "#{action}_" if action
  #
  #   h.send "#{action_path}#{topic.linked.db_entry_type.downcase}_critique_url",
  #     topic.linked.target,
  #     topic.linked
  # end
end
