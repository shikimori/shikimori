json.id @resource.id
json.html render(
  partial: 'comments/comment',
  formats: [:html],
  locals: {
    comment: @resource,
    topic: @resource.commentable
  }
)
