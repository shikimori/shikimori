class Forums::View < ViewObjectBase
  pattr_initialize :forum, %i[linked linked_forum]
  instance_cache :forum, :linked, :topic_views, :menu

  def forum
    Forum.find_by_permalink @forum
  end

  def linked
    return @linked if @linked
    return unless h.params[:linked_id]

    h.params[:linked_type].camelize.constantize.find(
      CopyrightedIds.instance.restore(
        h.params[:linked_id],
        h.params[:linked_type]
      )
    )
  end

  def topic_views # rubocop:disable Metrics/AbcSize
    Topics::Query.fetch(h.current_user, h.censored_forbidden?)
      .by_forum(forum, h.current_user, h.censored_forbidden?)
      .by_linked(linked)
      .search(h.params[:search], forum, h.current_user)
      .paginate(page, limit)
      .as_views(true, false)
  end

  def page_url page
    if linked.is_a? Club
      club_topics_url page
    else
      forum_topics_url page
    end
  end

  def next_page_url
    page_url topic_views.next_page if topic_views.next_page
  end

  def current_page_url
    page_url page
  end

  def prev_page_url
    page_url topic_views.prev_page if topic_views.prev_page
  end

  def faye_subscriptions
    return [] unless h.user_signed_in?
    return user_subscriptions unless forum&.permalink

    if linked_forum
      [linked_channel(linked)]
    else
      [forum_channel(forum.id)]
    end
  end

  def menu
    Forums::Menu.new forum, linked
  end

  def redirect_url
    h.url_for linked
  end

  def hidden?
    @forum == 'hidden'
  end

private

  def user_subscriptions
    user_forums = h.current_user.preferences.forums.select(&:present?)
    user_clubs = h.current_user.clubs_wo_shadowbanned

    user_forums.map { |id| forum_channel(id) } +
      user_clubs.map { |club| "/club-#{club.id}" }
  end

  def forum_channel forum_id
    "/forum-#{forum_id}"
  end

  def linked_channel linked
    "/#{linked.class.name.downcase}-#{linked.id}"
  end

  def club_topics_url page
    h.club_club_topics_url linked,
      page: (page unless page == 1),
      search: h.params[:search]
  end

  def forum_topics_url page
    h.forum_topics_url(
      page: (page unless page == 1),
      forum: forum.try(:permalink),
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      search: h.params[:search]
    )
  end

  def limit
    h.params[:format] == 'rss' ? 30 : 8
  end
end
