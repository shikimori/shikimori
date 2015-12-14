class Forums::View < ViewObjectBase
  instance_cache :fetch_topics, :section, :menu, :linked

  def section
    Section.find_by_permalink h.params[:section]
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
    case section && section.permalink
      when nil
        Section.real.map {|v| "section-#{v.id}" } +
          h.current_user.groups.map { |v| "group-#{v.id}" }

      #when Section::static[:feed].permalink
        #["user-#{current_user.id}", FayePublisher::BroadcastFeed]

      else
        ["section-#{section.id}"]
    end
  end

  def menu
    Forums::Menu.new section, linked
  end

  def linked
    case section.permalink
      when 'a'
        id = CopyrightedIds.instance.restore h.params[:linked], 'anime'
        Anime.find id

      when 'm'
        id = CopyrightedIds.instance.restore h.params[:linked], 'manga'
        Manga.find id

      when 'c'
        id = CopyrightedIds.instance.restore h.params[:linked], 'character'
        Character.find id

      when 'g'
        Group.find h.params[:linked].to_i

      when 'reviews'
        Review.find h.params[:linked]

      else
        nil

    end if h.params[:linked]
  end

private

  def page_url page
    h.section_url(
      page: page,
      section: section.try(:permalink),
      linked: h.params[:linked]
    )
  end

  def add_postloader?
    fetch_topics.last
  end

  def fetch_topics
    topics, add_postloader = TopicsQuery.new(h.current_user)
      .by_section(section)
      .by_linked(linked)
      .postload(page, limit)
      .result

    collection = topics.map do |topic|
      Topics::Factory.new(
        true,
        section && section.permalink == 'reviews'
      ).build topic
    end

    [collection, add_postloader]
  end
end
