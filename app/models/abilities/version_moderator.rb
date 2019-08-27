class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :rollback_episode, Anime
    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion)
    end
  end
end
