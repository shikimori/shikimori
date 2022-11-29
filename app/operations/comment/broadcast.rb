class Comment::Broadcast
  method_object :comment

  BB_CODE = '[broadcast]'

  def call
    @comment.update_column :body, "#{@comment.body}\n#{BB_CODE}"
    Comments::BroadcastNotifications.perform_async @comment.id
  end
end
