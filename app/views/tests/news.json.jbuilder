json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'tests/cached_news',
    locals: { view: @view },
    formats: :html
  )
)

if @view.news.next_page
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: news_tests_url(page: @view.news.next_page),
    prev_url: @view.news.prev_page ?
      news_tests_url(page: @view.news.prev_page) : nil
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
