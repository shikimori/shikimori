json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @collection,
    as: :topic_view,
    formats: :html,
    cached: true
  )
)

if @collection.size == controller.class::TOPICS_LIMIT
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-topic',
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
