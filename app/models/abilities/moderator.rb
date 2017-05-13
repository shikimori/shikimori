class Abilities::Moderator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, [Comment]
    can :manage, [Topic] do |topic|
      !topic.generated? ||
        Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
    end
    can %i[edit update], [Genre]
  end
end
