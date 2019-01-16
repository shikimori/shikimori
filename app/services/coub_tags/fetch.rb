class CoubTags::Fetch
  method_object %i[tags! iterator]

  PER_PAGE = 10

  def call
    fetch @tags.first, 1
  end

private

  def fetch tag, page, fetched_coubs: []
    all_coubs = CoubTags::CoubRequest.call tag, page
    anime_coubs = fetched_coubs + all_coubs.select(&:anime?)

    if finished?(all_coubs) || enough?(anime_coubs)
      results anime_coubs, next_iterator(all_coubs, tag, page)

    else
      fetch tag, page + 1, fetched_coubs: anime_coubs
    end
  end

  def results coubs, iterator
    Coub::Results.new coubs: coubs, iterator: iterator
  end

  def next_iterator coubs, tag, page
    "#{tag}:#{page + 1}" unless finished? coubs
  end

  def finished? coubs
    coubs.size < CoubTags::CoubRequest::PER_PAGE
  end

  def enough? coubs
    coubs.size == PER_PAGE
  end
end
