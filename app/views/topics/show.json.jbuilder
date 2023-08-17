json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'topics/topic',
    locals: {
      topic_view: @topic_view
    },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
