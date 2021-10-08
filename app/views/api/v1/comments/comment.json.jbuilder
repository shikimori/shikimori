json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(
  render(
    partial: 'comments/comment',
    object: @resource.decorate,
    formats: %i[html]
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
