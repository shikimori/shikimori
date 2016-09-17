json.id @resource.id
json.html JsExports::Supervisor.instance.sweep(render(
  partial: 'comments/comment',
  formats: [:html],
  locals: {
    comment: @resource,
    topic: @resource.commentable
  }
))

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
