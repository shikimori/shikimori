json.content render(
  partial: 'topics/topic',
  collection: @forums_view.topics,
  as: :topic_view,
  formats: :html
)

if @forums_view.next_page_url
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: @forums_view.next_page_url,
    prev_url: @forums_view.prev_page_url
end
