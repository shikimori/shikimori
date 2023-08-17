json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'messages/message',
    locals: {
      message: @resource
    },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
