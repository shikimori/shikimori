json.content render(
  partial: 'moderations/roles/user',
  collection: @searched_collection,
  locals: { with_action: true },
  formats: :html
)

if @searched_collection&.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-user',
    next_url: current_url(page: @searched_collection.next_page),
    prev_url: (
      current_url(page: @searched_collection.prev_page) if @searched_collection.prev_page?
    )
  )
end
