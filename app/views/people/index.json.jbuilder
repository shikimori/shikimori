json.content render(
  partial: @collection.first.is_a?(Person) ? 'people/person' : 'characters/character',
  collection: @collection,
  locals: { is_search_russian: search_russian? },
  formats: :html
)

if @collection.next_page?
  json.postloader render(
    'blocks/postloader',
    next_url: search_url(page: @collection.next_page, search: params[:search]),
    prev_url: (search_url(page: @collection.prev_page, search: params[:search]) if @collection.prev_page?), # rubocop:disable LineLength
    pages_limit: 15
  )
end
