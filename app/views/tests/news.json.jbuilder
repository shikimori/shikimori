json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @news,
    as: :topic_view,
    formats: :html
  )
)

if @news.next_page
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: news_tests_url(page: @news.next_page),
    prev_url: @news.prev_page ?
      news_tests_url(page: @news.prev_page) : nil
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
