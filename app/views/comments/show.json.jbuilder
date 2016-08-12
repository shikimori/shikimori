# fetched when user click on "reply" button
json.id @view.comment.id
#json.body @view.comment.body
json.offtopic @view.comment.offtopic?
json.user @view.comment.user.nickname
json.kind 'comment'

json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'comments/comment',
  locals: { comment: @view.comment.decorate },
  formats: :html
))

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
