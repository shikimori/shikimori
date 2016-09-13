class Abilities::ContestsModerator
  include CanCan::Ability

  def initialize user
    can :manage, Contest
    cannot :destroy, Contest
  end
end
