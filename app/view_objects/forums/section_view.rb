class Forums::SectionView < Forums::BaseView
  instance_cache :fetch_topics, :section

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

  def add_postloader?
    fetch_topics.last
  end

private

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
