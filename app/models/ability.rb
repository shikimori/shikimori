class Ability
  include CanCan::Ability

  def initialize user
    @user = user
    guest_ability

    if @user
      user_ability
      contests_moderator_ability if @user.contests_moderator?
    end
  end

  def guest_ability
    can [:read], Contest
  end

  def user_ability
    can :manage, UserRate, user_id: @user.id
    can [:cleanup, :reset], UserRate

    can :manage, Device, user_id: @user.id
  end

  def contests_moderator_ability
    can :manage, Contest
    cannot :destroy, Contest
  end
end
