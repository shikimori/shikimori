json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'comments/comment',
    collection: @collection,
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
