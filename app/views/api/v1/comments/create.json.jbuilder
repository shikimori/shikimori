json.id @comment.id
json.html render(
  'comments/comment',
  comment: @comment,
  topic: @comment.commentable
)
