class Comments::BroadcastNotifications
  include Sidekiq::Worker

  sidekiq_options dead: false

  def perform comment_id
    comment = Comment.find_by id: comment_id
    return unless comment

    messages = build_messages comment

    Message.transaction do
      Message.import messages
    end
  end

private

  def build_messages comment
    comment.commentable.linked
      .members
      .where.not(id: comment.user_id)
      .map { |user| build_message comment, user }
  end

  def build_message comment, user
    Message.new(
      from: comment.user,
      to: user,
      kind: MessageType::CLUB_BROADCAST,
      linked: comment,
      created_at: comment.created_at
    )
  end
end
