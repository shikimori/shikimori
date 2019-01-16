class CoubTags::Fetch
  method_object %i[tags! iterator]

  PER_PAGE = 10

  def call
    tag, page, overfetch = (iterator || "#{@tags.first}:1:0").split(':')

    fetch(
      tag: tag,
      page: page.to_i,
      overfetch: overfetch.to_i
    )
  end

private

  def fetch tag:, page:, overfetch: 0, add_coubs: []
    all_coubs = CoubTags::CoubRequest.call tag, page
    anime_coubs = (add_coubs + all_coubs.select(&:anime?))[overfetch..-1]
    overloaded_coubs = anime_coubs[PER_PAGE..-1] || []

    if finished?(all_coubs) || enough?(anime_coubs)
      Coub::Results.new(
        coubs: anime_coubs - overloaded_coubs,
        iterator: next_iterator(all_coubs, tag, page, overloaded_coubs)
      )

    else
      fetch(
        tag: tag,
        page: page + 1,
        add_coubs: anime_coubs
      )
    end
  end

  def next_iterator coubs, tag, page, overloaded_coubs
    return nil if finished? coubs

    if overloaded_coubs.any?
      "#{tag}:#{page}:#{overloaded_coubs.size}"
    else
      "#{tag}:#{page + 1}:0"
    end
  end

  def finished? coubs
    coubs.size < CoubTags::CoubRequest::PER_PAGE
  end

  def enough? coubs
    coubs.size >= PER_PAGE
  end
end
