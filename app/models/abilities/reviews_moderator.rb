class Abilities::ReviewsModerator
  include CanCan::Ability

  def initialize user
    can :manage, Review
  end
end
