json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(
  render(
    partial: 'messages/message',
    object: @resource.decorate,
    formats: %i[html]
  )
)
json.notice local_assigns[:notice]

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
