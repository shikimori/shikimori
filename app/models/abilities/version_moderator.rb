class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  NOT_MANAGED_FIELDS = Abilities::VersionTextsModerator::MANAGED_FIELDS +
    Abilities::VersionFansubModerator::MANAGED_FIELDS

  def initialize _user
    can :rollback_episode, Anime
    can :upload_episode, Anime

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys & NOT_MANAGED_FIELDS).none?
    end
  end
end
