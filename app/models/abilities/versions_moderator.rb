class Abilities::VersionsModerator
  include CanCan::Ability

  def initialize user
    can :manage, Version
  end
end
