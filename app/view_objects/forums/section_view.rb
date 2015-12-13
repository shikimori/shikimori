class Forums::SectionView < Forums::BaseView
  instance_cache :fetch_topics, :section

  def section
    Section.find_by_permalink h.params[:section] || 'all'
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
    case section.permalink
      when Section::static[:all].permalink
        Section.real.map {|v| "section-#{v.id}" } +
          h.current_user.groups.map { |v| "group-#{v.id}" }

      #when Section::static[:feed].permalink
        #["user-#{current_user.id}", FayePublisher::BroadcastFeed]

      else
        ["section-#{section.id}"]
    end
  end

private

  def page_url page
    h.section_url(
      page: page,
      section: section[:permalink],
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
        section.permalink == 'reviews'
      ).build topic
    end

    [collection, add_postloader]
  end
end
