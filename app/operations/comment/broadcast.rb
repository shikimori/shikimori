class Comment::Broadcast < ServiceObjectBase
  pattr_initialize :comment

  BB_CODE = '[broadcast]'

  def call
    comment.update body: "#{comment.body}\n#{BB_CODE}"
    Comments::BroadcastNotifications.perform_async comment.id
  end
end
