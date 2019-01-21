class Coubs::Fetch
  method_object %i[tags! iterator]

  PER_PAGE = 10

  def call
    return Coub::Results.new coubs: [], iterator: nil if @tags.none?

    tag, page, prior_index = parse_iterator(@iterator || default_iterator)

    fetch(
      tag: tag,
      page: page,
      prior_index: prior_index,
      add_coubs: []
    )
  end

private

  def parse_iterator value
    parts = value.split(':')

    [parts[0..-3].join(':'), parts[-2].to_i, parts[-1].to_i]
  end

  def fetch tag:, page:, prior_index:, add_coubs: [] # rubocop:disable MethodLength
    results = fetch_tag(
      tag: tag,
      page: page,
      prior_index: prior_index,
      add_coubs: add_coubs
    )

    if results.iterator.nil? && next_tag(tag)
      fetch(
        tag: next_tag(tag),
        page: 1,
        prior_index: -1,
        add_coubs: results.coubs
      )
    else
      results
    end
  end

  def default_iterator
    "#{@tags.first}:1:-1"
  end

  def next_tag tag
    @tags[tags.index(tag) + 1]
  end

  def fetch_tag tag:, page:, prior_index: -1, add_coubs: # rubocop:disable MethodLength
    fetched_coubs = Coubs::Request.call tag, page
    fetched_anime_coubs = fetched_coubs.select(&:anime?)

    all_coubs = add_coubs + fetched_anime_coubs
    anime_coubs = all_coubs[(prior_index + 1)..(prior_index + PER_PAGE)] || []

    next_index = fetched_anime_coubs.last == anime_coubs.last ?
      -1 :
      fetched_anime_coubs.index(anime_coubs.last)

    if finished?(fetched_coubs, next_index) || enough?(anime_coubs)
      Coub::Results.new(
        coubs: anime_coubs,
        iterator: next_iterator(fetched_coubs, tag, page, next_index)
      )

    else
      fetch_tag(
        tag: tag,
        page: page + 1,
        prior_index: -1,
        add_coubs: anime_coubs
      )
    end
  end

  def next_iterator coubs, tag, page, next_index
    return nil if finished? coubs, next_index

    next_page = next_index == -1 ? page + 1 : page

    "#{tag}:#{next_page}:#{next_index}"
  end

  def finished? coubs, next_index
    coubs.empty? || (
      coubs.size < Coubs::Request::PER_PAGE &&
      next_index == -1
    )
  end

  def enough? coubs
    coubs.size == PER_PAGE
  end
end
