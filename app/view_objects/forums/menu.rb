class Forums::Menu < ViewObjectBase
  pattr_initialize :forum, :linked
  instance_cache :club_topics, :contests, :reviews

  def club_topics
    Topic
      .includes(:linked)
      .where(type: [
        Topics::EntryTopics::ClubTopic,
        Topics::ClubUserTopic,
        Topics::EntryTopics::ClubPageTopic,
      ])
      .where(locale: h.locale_from_host)
      .order(updated_at: :desc)
      .limit(3)
  end

  def contests
    Contest.current
  end

  def changeable_forums?
    h.user_signed_in? && h.params[:action] == 'index' && h.params[:forum].nil?
  end

  def forums
    Forums::List.new with_forum_size: true
  end

  def reviews
    @reviews ||= Review
      .where('created_at >= ?', 2.weeks.ago)
      .where(locale: h.locale_from_host)
      .visible
      .includes(:user, :target, topics: [:forum])
      .order(created_at: :desc)
      .limit(3)
  end

  def sticky_topics
    if h.ru_host?
      [
        StickyTopicView.site_rules(h.locale_from_host),
        StickyTopicView.faq(h.locale_from_host),
        StickyTopicView.description_of_genres(h.locale_from_host),
        StickyTopicView.ideas_and_suggestions(h.locale_from_host),
        StickyTopicView.site_problems(h.locale_from_host)
      ]
    else
      [
        StickyTopicView.site_rules(h.locale_from_host),
        StickyTopicView.ideas_and_suggestions(h.locale_from_host),
        StickyTopicView.site_problems(h.locale_from_host)
      ]
    end
  end

  def new_topic_url
    h.new_topic_url(
      forum: forum,
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      'topic[type]' => Topic.name,
      'topic[user_id]' => h.current_user.id,
      'topic[forum_id]' => forum ? forum.id : nil,
      'topic[linked_id]' => linked ? linked.id : nil,
      'topic[linked_type]' => linked ? linked.class.name : nil
    )
  end
end
