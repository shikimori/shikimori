class Coubs::Fetch
  method_object %i[tags! iterator]

  PER_PAGE = 10

  def call
    return Coub::Results.new coubs: [], iterator: nil if @tags.none?

    tag, page, overfetched = (@iterator || default_iterator).split(':')

    fetch(
      tag: tag,
      page: page.to_i,
      overfetched: overfetched.to_i,
      add_coubs: []
    )
  end

private

  def fetch tag:, page:, overfetched:, add_coubs: [] # rubocop:disable MethodLength
    results = fetch_tag(
      tag: tag,
      page: page,
      overfetched: overfetched,
      add_coubs: add_coubs
    )

    if results.iterator.nil? && next_tag(tag)
      fetch(
        tag: next_tag(tag),
        page: 1,
        overfetched: 0,
        add_coubs: results.coubs
      )
    else
      results
    end
  end

  def default_iterator
    "#{@tags.first}:1:0"
  end

  def next_tag tag
    tags[tags.index(tag) + 1]
  end

  def fetch_tag tag:, page:, overfetched: 0, add_coubs: # rubocop:disable MethodLength
    all_coubs = Coubs::Request.call tag, page
    anime_coubs = (add_coubs + all_coubs.select(&:anime?))[overfetched..-1]
    overloaded_coubs = anime_coubs[PER_PAGE..-1] || []

    if finished?(all_coubs) || enough?(anime_coubs)
      Coub::Results.new(
        coubs: anime_coubs - overloaded_coubs,
        iterator: next_iterator(all_coubs, tag, page, overloaded_coubs)
      )

    else
      fetch_tag(
        tag: tag,
        page: page + 1,
        overfetched: 0,
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
    coubs.size < Coubs::Request::PER_PAGE
  end

  def enough? coubs
    coubs.size >= PER_PAGE
  end
end
