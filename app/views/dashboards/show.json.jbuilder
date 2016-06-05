json.content render(
  partial: 'topics/topic',
  collection: @dashboard_view.news_topic_views,
  as: :topic_view,
  formats: :html
)

if @dashboard_view.news_topic_views.next_page
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: root_page_url(page: @dashboard_view.news_topic_views.next_page),
    prev_url: root_page_url(page: @dashboard_view.news_topic_views.prev_page)
end
