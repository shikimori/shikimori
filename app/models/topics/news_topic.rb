class Topics::NewsTopic < Topic
  enumerize :action,
    in: Types::Topic::NewsTopic::Action.values,
    predicates: true

  scope :pending, -> { where forum_id: Forum::PREMODERATION_ID }

  def title
    return super unless generated?

    if episode?
      "#{action_text} #{value}".capitalize
    else
      action_text.capitalize
    end
  end

  # для message
  def full_title
    return title unless generated?

    BbCodes::Text
      .call(
        I18n.t(
          "topics/news_topic.full_title.#{linked_type.underscore}",
          action_name: title,
          action_name_lower: title.downcase,
          id: linked_id,
          type: linked_type.underscore
        )
      )
      .gsub(%r{<span class="name-ru">.*?</span>}, '')
      .gsub(/<.*?>/, '')
  end

  def accept
    update forum_id: Forum::NEWS_ID, created_at: Time.zone.now
  end

  def moderation_accepted?
    moderation_state == Types::Moderatable::State[:accepted]
  end

  def reject
    update forum_id: Forum::OFFTOPIC_ID # , created_at: Time.zone.now
  end

  def may_accept?
    forum_id != Forum::NEWS_ID
  end

  def may_reject?
    forum_id != Forum::OFFTOPIC_ID
  end

  def moderation_state
    if may_accept? && may_reject?
      Types::Moderatable::State[:pending]
    elsif may_accept?
      Types::Moderatable::State[:rejected]
    elsif may_reject?
      Types::Moderatable::State[:accepted]
    end
  end

  def offtopic?
    forum_id == Forum::OFFTOPIC_ID
  end
end
