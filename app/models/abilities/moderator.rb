class Abilities::Moderator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, [Comment]
    can :manage, [Topic] do |topic|
      !topic.generated? || topic.user_id == user.id
    end
    can [:edit, :update], [Genre]
  end
end
