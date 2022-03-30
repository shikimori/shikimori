json.content render(
  partial: 'animes/variants/list_item',
  collection: @collection,
  as: :entry,
  locals: {
    no_user_rate: true,
    with_status: true,
    is_search_russian: search_russian?
  },
  formats: :html
)

# json.postloader render(
#   partial: 'blocks/postloader',
#   locals: {
#     filter: 'b-topic',
#     next_url: @forums_view.next_page_url,
#     prev_url: @forums_view.prev_page_url
#   },
#   formats: :html
# )
