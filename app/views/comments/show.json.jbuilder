json.id @comment.id
json.body @comment.body
json.offtopic @comment.offtopic?
json.user @comment.user.nickname
json.kind 'comment'
