json.content render(
  partial: @collection.first.is_a?(Person) ? 'people/person' : 'characters/character',
  collection: @collection,
  locals: {
    is_search_russian: search_russian?
  },
  formats: :html
)

if @collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @collection.next_page),
      prev_url: (
        current_url(page: @collection.prev_page) if @collection.prev_page?
      ),
      pages_limit: 15
    },
    formats: :html
  )
end
