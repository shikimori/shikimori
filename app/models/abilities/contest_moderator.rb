class Abilities::ContestModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Contest
    cannot :destroy, Contest

    can %i[
      manage_cheat_bot_role
    ], User
  end
end
