json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'comments/comment',
    locals: {
      comment: @view.comment.decorate
    },
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
