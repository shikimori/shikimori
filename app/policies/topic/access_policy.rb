class Topic::AccessPolicy
  static_facade :allowed?, :topic, :current_user

  def self.linked_club topic
    case topic
      when Topics::EntryTopics::ClubTopic, Topics::ClubUserTopic
        topic.linked

      when Topics::EntryTopics::ClubPageTopic
        topic.linked.club
    end
  end

  def allowed?
    club = self.class.linked_club @topic

    if club
      Club::AccessPolicy.allowed? club, @current_user
    elsif premoderation_forum? || hidden_forum?
      author? || moderator?
    else
      true
    end
  end

private

  def author?
    @topic.user_id == @current_user&.id
  end

  def moderator?
    !!(@current_user&.moderation_staff? || @current_user&.news_moderator?)
  end

  def premoderation_forum?
    @topic.forum_id == Forum::PREMODERATION_ID
  end

  def hidden_forum?
    @topic.forum_id == Forum::HIDDEN_ID
  end
end
