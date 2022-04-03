json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @forums_view.topic_views,
    as: :topic_view,
    formats: :html,
    cached: ->(entry) { cache_keys entry }
  )
)

if @forums_view.next_page_url
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-topic',
      next_url: @forums_view.next_page_url,
      prev_url: @forums_view.prev_page_url
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
