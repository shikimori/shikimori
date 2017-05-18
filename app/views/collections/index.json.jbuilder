json.content render(
  partial: 'topics/topic',
  collection: @collection_views,
  as: :topic_view,
  cache: true
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-club',
    next_url: collections_url(page: @page+1)
  )
end
