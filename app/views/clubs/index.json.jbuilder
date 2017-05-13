json.content render(
  partial: 'clubs/club',
  collection: @collection,
  locals: { content_by: :detailed },
  cache: ->(entry, _) { CacheHelper.keys entry, :detailed },
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-club',
    next_url: page_clubs_url(page: @page+1)
  )
end
