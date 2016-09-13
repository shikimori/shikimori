class Abilities::Moderator
  include CanCan::Ability

  def initialize user
    can :manage, [Topic]
    cannot :manage, [Topic] do |topic|
      topic.generated? && !topic.is_a?(Topics::EntryTopics::ReviewTopic)
    end
    can [:edit, :update], [Genre]
  end
end
