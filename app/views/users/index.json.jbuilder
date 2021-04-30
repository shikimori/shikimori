json.content render(
  partial: 'users/user',
  collection: @collection,
  locals: { content_by: :detailed },
  formats: :html
)

if @collection&.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-user',
    next_url: current_url(page: @collection.next_page),
    prev_url: (
      current_url(page: @collection.prev_page) if @collection.prev_page?
    ),
    pages_limit: 10
  )
end
