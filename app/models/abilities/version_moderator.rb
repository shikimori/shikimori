class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  NOT_MANAGED_FIELDS = Abilities::VersionTextsModerator::MANAGED_FIELDS +
    Abilities::VersionNamesModerator::MANAGED_FIELDS +
    Abilities::VersionFansubModerator::MANAGED_FIELDS

  MANAGED_MODELS = Abilities::VersionTextsModerator::MANAGED_MODELS

  def initialize _user
    can :increment_episode, Anime
    can :rollback_episode, Anime
    can :upload_episode, Anime

    can :sync, [Anime, Manga, Person, Character]

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff && (
          (version.item_diff.keys & NOT_MANAGED_FIELDS).none? ||
          !MANAGED_MODELS.include?(version.item_type)
        )
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end
