json.id @view.comment.id
#json.body @view.comment.body
json.offtopic @view.comment.offtopic?
json.user @view.comment.user.nickname
json.kind 'comment'
