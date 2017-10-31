class Abilities::ReviewModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, Review
  end
end
