json.content render(
  partial: 'topics/topic',
  collection: @view.news_topics,
  as: :topic_view,
  formats: :html
)

if @view.news_topics.next_page
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: root_page_url(page: @view.news_topics.next_page),
    prev_url: root_page_url(page: @view.news_topics.prev_page)
end
