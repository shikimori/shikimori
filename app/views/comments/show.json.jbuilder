json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'comments/comment',
    locals: {
      comment: @view.comment.decorate
    },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
