json.content render(
  partial: 'clubs/club',
  collection: @collection,
  locals: { content_by: :detailed },
  cache: ->(entry, _) { CacheHelper.keys entry, :detailed },
  formats: :html
)

if @collection.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-club',
    next_url: page_clubs_url(page: @collection.next_page, search: params[:search]),
    prev_url: (page_clubs_url(page: @collection.prev_page, search: params[:search]) if @collection.prev_page?)
  )
end
