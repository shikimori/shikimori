json.id @comment.id
json.html render(
  partial: 'comments/comment',
  formats: [:html],
  locals: {
    comment: @comment,
    topic: @comment.commentable
  }
)
