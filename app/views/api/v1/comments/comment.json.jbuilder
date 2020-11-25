json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(
  render(
    partial: 'comments/comment',
    locals: {
      comment: @resource,
      topic: @resource.commentable
    },
    formats: %i[html]
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
