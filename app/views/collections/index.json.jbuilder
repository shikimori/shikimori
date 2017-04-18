json.content render(
  partial: 'collections/collection',
  collection: @collection,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-club',
    next_url: page_collections_url(page: @page+1)
  )
end
