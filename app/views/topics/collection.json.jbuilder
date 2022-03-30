json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @collection,
    as: :topic_view,
    formats: :html,
    cached: true
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
