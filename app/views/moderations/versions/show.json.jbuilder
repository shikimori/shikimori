json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'versions/version',
    object: @resource.decorate,
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
