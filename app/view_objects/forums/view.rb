class Forums::View < ViewObjectBase
  pattr_initialize :forum, [:linked]
  instance_cache :forum, :linked, :topic_views, :menu

  def forum
    Forum.find_by_permalink @forum
  end

  def linked
    return @linked if @linked

    h.params[:linked_type].camelize.constantize.find(
      CopyrightedIds.instance.restore(
        h.params[:linked_id],
        h.params[:linked_type]
      )
    ) if h.params[:linked_id]
  end

  def topic_views
    Topics::Query.fetch(h.current_user, h.locale_from_host)
      .by_forum(forum, h.current_user, h.censored_forbidden?)
      .by_linked(linked)
      .paginate(page, limit)
      .as_views(true, forum && forum.permalink == 'reviews')
  end

  def next_page_url
    page_url topic_views.next_page if topic_views.next_page
  end

  def prev_page_url
    page_url topic_views.prev_page if topic_views.prev_page
  end

  def faye_subscriptions
    return [] unless h.user_signed_in?

    case forum && forum.permalink
      when nil
        user_forums = h.current_user.preferences.forums.select(&:present?)
        user_clubs = h.current_user.clubs_for_domain

        user_forums.map { |id| forum_channel(id, h.locale_from_host) } +
          user_clubs.map { |club| "club-#{club.id}" }

      #when Forum::static[:feed].permalink
        #["user-#{current_user.id}", FayePublisher::BroadcastFeed]

      else
        ["forum-#{forum.id}"]
    end
  end

  def forum_channel forum_id, locale
    "forum-#{forum_id}/#{locale}"
  end

  def menu
    Forums::Menu.new forum, linked
  end

  def form
    Forums::Form.new
  end

  def page
    (h.params[:page] || 1).to_i
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

  def limit
    h.params[:format] == 'rss' ? 30 : 8
  end
end
