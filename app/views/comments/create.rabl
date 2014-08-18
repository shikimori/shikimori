object @comment

attribute :id

node(:notice) { @notice }
node :html do |comment|
  render_to_string(
    partial: 'comments/comment',
    locals: {
      comment: comment,
      topic: comment.commentable
    }
  )
end
