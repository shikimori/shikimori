class Ability
  include CanCan::Ability

  def initialize user
    return unless user

    can :manage, UserRate, user_id: user.id
    can [:cleanup, :reset], UserRate

    can :manage, Device, user_id: user.id
  end
end
