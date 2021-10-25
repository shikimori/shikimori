json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'comments/comment',
    collection: @collection,
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
