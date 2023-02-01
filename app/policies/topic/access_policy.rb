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

    club ?
      Club::AccessPolicy.allowed?(club, @current_user) :
      moderator? || author? || !in_premoderation?
  end

private

  def moderator?
    @current_user&.moderation_staff?
  end

  def author?
    @topic.user_id == @current_user&.id
  end

  def in_premoderation?
    @topic.forum_id == Forum::PREMODERATION_ID
  end
end
