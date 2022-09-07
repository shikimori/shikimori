class Topic::AccessPolicy
  static_facade :allowed?, :topic, :current_user

  def allowed?
    club = linked_club @topic

    club ?
      Club::AccessPolicy.allowed?(club, current_user) :
      true
  end

private

  def linked_club topic
    case topic
      when Topics::EntryTopics::ClubTopic, Topics::ClubUserTopic
        topic.linked

      when Topics::EntryTopics::ClubPageTopic
        topic.linked.club
    end
  end
end
