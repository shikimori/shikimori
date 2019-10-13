json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @dashboard_view.news,
    as: :topic_view,
    formats: :html
  )
)

if @dashboard_view.news.next_page
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: news_tests_url(page: @dashboard_view.news.next_page),
    prev_url: @dashboard_view.news.prev_page ?
      news_tests_url(page: @dashboard_view.news.prev_page) : nil
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
