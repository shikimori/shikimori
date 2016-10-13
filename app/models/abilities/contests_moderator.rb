class Abilities::ContestsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, Contest
    cannot :destroy, Contest
  end
end
