class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, Version
  end
end
