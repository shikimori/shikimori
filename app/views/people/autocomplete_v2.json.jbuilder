json.content render(
  partial: 'people/variants/list_item',
  collection: @collection,
  as: :entry,
  locals: {
    is_search_russian: search_russian?
  },
  formats: :html
)

# json.postloader render 'blocks/postloader',
#   filter: 'b-topic',
#   next_url: @forums_view.next_page_url,
#   prev_url: @forums_view.prev_page_url
