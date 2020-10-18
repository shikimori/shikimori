class Topics::EntryTopic < Topic
  DEFAULT_TITLE = I18n.t 'topics/entry_topic.title.default'

  def title
    I18n.t(
      "topics/entry_topic.title.#{linked.class.name.underscore}",
      default: DEFAULT_TITLE
    )
  end

  # used in Messages::MentionSource
  def full_title
    return title unless generated?

    BbCodes::Text
      .call(
        I18n.t(
          "topics/entry_topic.full_title.#{linked.class.name.underscore}",
          i18n_params
        )
      )
      .gsub(%r{<span class="name-ru">.*?</span>}, '')
      .gsub(/<.*?>/, '')
  end

  def body
    I18n.t(
      "topics/entry_topic.body.#{linked.class.name.underscore}",
      i18n_params
    )
  end

private

  def i18n_params
    { id: linked_id }
  end
end
