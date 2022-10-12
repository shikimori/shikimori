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
    return true if !club || moderator?

    Club::AccessPolicy.allowed? club, @current_user
  end

private

  def moderator?
    @current_user&.moderation_staff?
  end
end
