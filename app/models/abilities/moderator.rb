class Abilities::Moderator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, [Comment]
    can :manage, [Topic]
    cannot :manage, [Topic] do |topic|
      topic.generated? && !topic.is_a?(Topics::EntryTopics::ReviewTopic)
    end
    can [:edit, :update], [Genre]
  end
end
