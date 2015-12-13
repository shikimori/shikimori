json.content render(
  partial: 'topics/topic',
  collection: @view.topics,
  as: :view,
  formats: :html
)

if @view.next_page_url
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: @view.next_page_url,
    prev_url: @view.prev_page_url
end
