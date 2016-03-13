class Forums::View < ViewObjectBase
  instance_cache :fetch_topics, :forum, :menu, :linked

  def forum
    Forum.find_by_permalink h.params[:forum]
  end

  def topics
    fetch_topics.first
  end

  def page
    (h.params[:page] || 1).to_i
  end

  def limit
    h.params[:format] == 'rss' ? 30 : 8
  end

  def next_page_url
    page_url page + 1 if add_postloader?
  end

  def prev_page_url
    page_url page - 1 if page != 1
  end

  def faye_subscriptions
    case forum && forum.permalink
      when nil
        user_forums = h.current_user.preferences.forums.select(&:present?)
        user_clubs = h.current_user.clubs

        user_forums.map { |id| "forum-#{id}" } +
          user_clubs.map { |club| "club-#{club.id}" }

      #when Forum::static[:feed].permalink
        #["user-#{current_user.id}", FayePublisher::BroadcastFeed]

      else
        ["forum-#{forum.id}"]
    end
  end

  def menu
    Forums::Menu.new forum, linked
  end

  def linked
    h.params[:linked_type].camelize.constantize.find(
      CopyrightedIds.instance.restore(
        h.params[:linked_id],
        h.params[:linked_type]
      )
    ) if h.params[:linked_id]
  end

  def form
    Forums::Form.new
  end

private

  def page_url page
    h.forum_topics_url(
      page: page,
      forum: forum.try(:permalink),
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type]
    )
  end

  def add_postloader?
    fetch_topics.last
  end

  def fetch_topics
    topics, add_postloader = TopicsQuery.new(h.current_user, h.censored_forbidden?)
      .by_forum(forum)
      .by_linked(linked)
      .postload(page, limit)
      .result

    collection = topics.map do |topic|
      Topics::TopicViewFactory.new(
        true,
        forum && forum.permalink == 'reviews'
      ).build topic
    end

    [collection, add_postloader]
  end
end
