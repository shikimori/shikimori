class Comment::AccessPolicy
  static_facade :allowed?, :comment, :decorated_user

  def allowed?
    club = linked_club
    return true unless club

    !club.shadowbanned? || (
      club.shadowbanned? && !!@decorated_user&.club_ids&.include?(club.id)
    )
  end

private

  def linked_club
    case @comment.commentable
      when Topics::EntryTopics::ClubTopic
        @comment.commentable.linked

      when Topics::EntryTopics::ClubPageTopic
        @comment.commentable.linked.club

      when Topics::ClubUserTopic
        @comment.commentable.linked.linked
    end
  end
end
