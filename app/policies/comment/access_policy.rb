class Comment::AccessPolicy
  static_facade :allowed?, :comment, :current_user

  def allowed?
    club = linked_club @comment.commentable

    return true unless club
    return false if club.censored? && !@current_user

    shadowban_check club
  end

private

  def linked_club commentable
    case commentable
      when Topics::EntryTopics::ClubTopic, Topics::ClubUserTopic
        commentable.linked

      when Topics::EntryTopics::ClubPageTopic
        commentable.linked.club
    end
  end

  def shadowban_check club
    !club.shadowbanned? || (
      club.shadowbanned? && !!@current_user&.club_ids&.include?(club.id)
    )
  end
end
