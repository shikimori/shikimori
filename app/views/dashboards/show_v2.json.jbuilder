json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'dashboards/cached_news',
    locals: {
      view: @view
    },
    formats: :html
  )
)

if @view.news_topic_views.next_page
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-topic',
      next_url: root_page_url(page: @view.news_topic_views.next_page),
      prev_url: @view.news_topic_views.prev_page ?
        root_page_url(page: @view.news_topic_views.prev_page) : nil
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
