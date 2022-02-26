class Forums::Menu < ViewObjectBase
  pattr_initialize :forum, :linked
  instance_cache :club_topics, :critiques

  def club_topics
    Topic
      .includes(:linked)
      .where(
        type: [
          Topics::EntryTopics::ClubTopic.name,
          Topics::ClubUserTopic.name,
          Topics::EntryTopics::ClubPageTopic.name
        ]
      )
      .where(locale: h.locale_from_host)
      .order(updated_at: :desc)
      .limit(3)
  end

  def changeable_forums?
    h.user_signed_in? && h.params[:action] == 'index' && h.params[:forum].nil?
  end

  def forums
    Forums::List.new with_forum_size: true
  end

  def critiques
    @critiques ||= Critique
      .where('created_at >= ?', 2.weeks.ago)
      .where(locale: h.locale_from_host)
      .visible
      .includes(:user, :target, topics: [:forum])
      .order(created_at: :desc)
      .limit(3)
  end

  def sticky_topics
    if h.ru_host?
      ru_sticky_topics
    else
      en_sticky_topics
    end
  end

  def new_topic_url # rubocop:disable AbcSize
    h.new_topic_url(
      forum: forum,
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      'topic[user_id]' => h.current_user&.id,
      'topic[forum_id]' => forum ? forum.id : nil,
      'topic[linked_id]' => linked ? linked.id : nil,
      'topic[linked_type]' => linked ? linked.class.name : nil
    )
  end

  def new_news_url # rubocop:disable AbcSize
    h.new_topic_url(
      forum: forum,
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      'topic[user_id]' => h.current_user&.id,
      'topic[forum_id]' => forum ? forum.id : Forum::NEWS_ID,
      'topic[linked_id]' => linked ? linked.id : nil,
      'topic[linked_type]' => linked ? linked.class.name : nil,
      'topic[type]' => Topics::NewsTopic.name
    )
  end

  def new_critique_url
    h.new_topic_url(
      forum: Forum.critiques,
      'topic[user_id]' => h.current_user&.id,
      'topic[forum_id]' => forum ? forum.id : nil
    )
  end

  def new_article_url
    h.new_article_url(article: { user_id: h.current_user&.id })
  end

  def new_collection_url
    h.new_collection_url(collection: { user_id: h.current_user&.id })
  end

private

  def ru_sticky_topics
    [
      StickyTopicView.site_rules(h.locale_from_host),
      StickyClubView.faq(h.locale_from_host),
      StickyTopicView.contests_proposals(h.locale_from_host),
      StickyTopicView.description_of_genres(h.locale_from_host),
      StickyTopicView.ideas_and_suggestions(h.locale_from_host),
      StickyTopicView.site_problems(h.locale_from_host)
    ]
  end

  def en_sticky_topics
    [
      StickyTopicView.site_rules(h.locale_from_host),
      StickyTopicView.ideas_and_suggestions(h.locale_from_host),
      StickyTopicView.site_problems(h.locale_from_host)
    ]
  end
end
