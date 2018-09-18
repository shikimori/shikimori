class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion)
    end
  end
end
