class Forums::List  < ViewObjectBase
  include Enumerable

  instance_cache :all

  def each
    sections.each { |section| yield section }
  end

private

  def sections
    Rails.cache.fetch([:sections, Entry.last.id], expires_in: 2.weeks) { all }
  end

  def all
    Section.visible.map do |section|
      size = TopicsQuery
        .new(h.current_user)
        .by_section(section)
        .where('comments_count > 0')
        .size

      OpenStruct.new(
        name: section.name,
        url: h.section_topics_url(section),
        size: size
      )
    end
  end
end
